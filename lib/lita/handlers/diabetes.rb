module Lita
    module Handlers
        class Diabetes < Handler
            @@conversionRatio = 18.0182

            route(/(?:^|_)(\d{1,3}|\d{1,2}\.\d+)(?:$|_)/, :convert, command: false, help:{
                '<number>' => 'Convert glucose between mass/molar concentration units.',
                '_<number>_' => 'Convert glucose between mass/molar concentration units inline. E.g "I started at _125_ today"'
                })

            route(/estimate a1c(?: from average)?\s+(\d{1,3}|\d{1,2}\.\d+)$/i, :estimateA1c, command: true, help: {
                'estimate a1c [from average] <glucose level>' => 'Estimates A1C based on average BG level'
            })
            route(/estimate average(?: from a1c)?\s+(\d{1,3}|\d{1,2}\.\d+)$/i, :estimateAverageFromA1c, command: true, help: {
                'estimate average [from a1c] <A1C>' => 'Estimates average blood glucose'
            })

            def convert(response)
                input = response.matches[0][0]
                Lita.logger.debug('Converting BG for input "' + input + '"')
                if input.index('.') == nil then
                    response.reply(input + ' mg/dL is ' + mgdlToMmol(input).to_s + ' mmol/L')
                else
                    response.reply(input + ' mmol/L is ' + mmolToMgdl(input).to_s + ' mg/dL')
                end
            end

            def estimateA1c(response)
                input = response.matches[0][0]
                Lita.logger.debug('Estimating a1c for input "' + input + '"')
                mmol = 0
                mgdl = 0

                if input.index('.') == nil then
                    mgdl = input.to_i
                    mmol = mgdlToMmol(mgdl)
                else
                    mmol = input.to_f.round(1)
                    mgdl = mmolToMgdl(mmol)
                end

                dcct = mgdlToDcct(mgdl)
                reply = 'an average of ' + mgdl.to_s + ' mg/dL or '
                reply = reply + mmol.to_s + ' mmol/L'
                reply = reply + ' is about '
                reply = reply + dcct.round(1).to_s + '% (DCCT) or '
                reply = reply + dcctToIfcc(dcct).round(0).to_s + ' mmol/mol (IFCC)'
                response.reply(reply)
            end

            def estimateAverageFromA1c(response)
                input = response.matches[0][0]
                Lita.logger.debug('Converting a1c to BG for input "' + input + '"')
                a1c = input.to_f
                dcct = 0
                ifcc = 0

                if input.index('.') == nil then
                    ifcc = a1c.round(0)
                    dcct = ifccToDcct(a1c).round(1)
                else
                    dcct = a1c.round(1)
                    ifcc = dcctToIfcc(a1c).round
                end

                mgdl = dcctToMgdl(dcct)

                reply = 'an A1C of ' + dcct.to_s + '% (DCCT) or '
                reply = reply + ifcc.to_s + ' mmol/mol (IFCC)'
                reply = reply + ' is about '
                reply = reply + mgdl.round.to_s + ' mg/dL or '
                reply = reply + mgdlToMmol(mgdl).round(1).to_s + ' mmol/L'
                response.reply(reply)
            end

            def mgdlToMmol(n)
                return (n.to_i / @@conversionRatio).round(1)
            end

            def mmolToMgdl(n)
                return (n.to_f * @@conversionRatio).round
            end

            def mgdlToDcct(n)
                return ((n.to_i + 46.7) / 28.7)
            end

            def mgdlToIfcc(n)
                return ((mgdlToDcct(n) - 2.15) * 10.929)
            end
            
            def dcctToIfcc(n)
                return (n.to_f - 2.15) * 10.929
            end

            def ifccToDcct(n)
                return (n.to_f / 10.929) + 2.15
            end

            def dcctToMgdl(n)
                return (n.to_f * 28.7) - 46.7
            end

            def ifccToMgdl(n)
                return dcctToMgdl((n / 10.929) + 2.5)
            end
        end

        Lita.register_handler(Diabetes)
    end
end
