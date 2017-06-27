require 'uri'

module Lita
  module Handlers
    class Diabetes < Handler
      @@conversionRatio = 18.0182
      config :lower_bg_bound
      config :upper_bg_bound

      route(/(?:^(?=\d)|\b_(?=\d+(?:\.\d+)?+(?:_|\s*$))|\b(?=\d+(?:\.\d+)?\s*(?:mm|mg)))((?<!\d\.)\d{1,3}|\d{1,2}\.\d+)\s*(?:(mmol(?:\/l)?|\mg\/?dl)|(?<=\d)_|$)/i, :convert, command: false, help: {
              '<number>' => 'Convert glucose between mass/molar concentration units.',
              '_<number>_' => 'Convert glucose between mass/molar concentration units inline. E.g "I started at _125_ today"'
            })

      route(/estimate a1c(?: from average)?\s+(\d{1,3}|\d{1,2}\.\d+)$/i, :estimate_a1c, command: true, help: {
              'estimate a1c [from average] <glucose level>' => 'Estimates A1C based on average BG level'
            })
      route(/estimate average(?: from a1c)?\s+(\d{1,3}|\d{1,2}\.\d+)$/i, :estimate_average_from_a1c, command: true, help: {
              'estimate average [from a1c] <A1C>' => 'Estimates average blood glucose'
            })

      def convert(response)
        return unless response.message.body.match(URI.regexp(%w[http https])).nil?
        input = response.matches[0][0]
        units = response.matches[0][1] || ''
        Lita.logger.debug("Converting BG for input \"#{input}\"")
        if input.to_f > config.lower_bg_bound.to_f && \
           input.to_f < config.upper_bg_bound.to_f && \
           units == ''
          Lita.logger.debug 'Ambiguous bg found, returning both results'
          resp = "Not sure if you meant mg/dl or mmol/L - #{input} is "
          resp += "#{mmol_to_mgdl(input)} mg/dl or "
          resp += "#{mgdl_to_mmol(input)} mmol/L"
          response.reply(resp)
        elsif !/mmol(\/l)?/i.match(units).nil?
          Lita.logger.debug 'Found mmol/L units'
          response.reply(input + " mmol/L is #{mmol_to_mgdl(input)} mg/dL")
        elsif !/mg\/?dl/i.match(units).nil?
          Lita.logger.debug 'Found mg/dl units'
          response.reply(input + " mg/dL is #{mgdl_to_mmol(input)} mmol/L")
        elsif input.index('.').nil?
          Lita.logger.debug 'Did not find decimal, assuming mg/dl'
          response.reply(input + " mg/dL is #{mgdl_to_mmol(input)} mmol/L")
        else
          Lita.logger.debug 'assuming mmol/L'
          response.reply(input + " mmol/L is #{mmol_to_mgdl(input)} mg/dL")
        end
      end

      def estimate_a1c(response)
        input = response.matches[0][0]
        Lita.logger.debug("Estimating a1c for input '#{input}")
        mmol = 0
        mgdl = 0

        if input.index('.').nil?
          mgdl = input.to_i
          mmol = mgdl_to_mmol(mgdl)
        else
          mmol = input.to_f.round(1)
          mgdl = mmol_to_mgdl(mmol)
        end

        dcct = mgdl_to_dcct(mgdl)
        reply = 'an average of ' + mgdl.to_s + ' mg/dL or '
        reply = reply + mmol.to_s + ' mmol/L'
        reply += ' is about '
        reply = reply + dcct.round(1).to_s + '% (DCCT) or '
        reply = reply + dcct_to_ifcc(dcct).round(0).to_s + ' mmol/mol (IFCC)'
        response.reply(reply)
      end

      def estimate_average_from_a1c(response)
        input = response.matches[0][0]
        Lita.logger.debug('Converting a1c to BG for input "' + input + '"')
        a1c = input.to_f
        dcct = 0
        ifcc = 0

        if input.index('.').nil?
          ifcc = a1c.round(0)
          dcct = ifcc_to_dcct(a1c).round(1)
        else
          dcct = a1c.round(1)
          ifcc = dcct_to_ifcc(a1c).round
        end

        mgdl = dcct_to_mgdl(dcct)

        reply = 'an A1C of ' + dcct.to_s + '% (DCCT) or '
        reply = reply + ifcc.to_s + ' mmol/mol (IFCC)'
        reply += ' is about '
        reply = reply + mgdl.round.to_s + ' mg/dL or '
        reply = reply + mgdl_to_mmol(mgdl).round(1).to_s + ' mmol/L'
        response.reply(reply)
      end

      def mgdl_to_mmol(n)
        (n.to_i / @@conversionRatio).round(1)
      end

      def mmol_to_mgdl(n)
        (n.to_f * @@conversionRatio).round
      end

      def mgdl_to_dcct(n)
        ((n.to_i + 46.7) / 28.7)
      end

      def mgdl_to_ifcc(n)
        ((mgdl_to_dcct(n) - 2.15) * 10.929)
      end

      def dcct_to_ifcc(n)
        (n.to_f - 2.15) * 10.929
      end

      def ifcc_to_dcct(n)
        (n.to_f / 10.929) + 2.15
      end

      def dcct_to_mgdl(n)
        (n.to_f * 28.7) - 46.7
      end

      def ifcc_to_mgdl(n)
        dcct_to_mgdl((n / 10.929) + 2.5)
      end
    end

    Lita.register_handler(Diabetes)
  end
end
