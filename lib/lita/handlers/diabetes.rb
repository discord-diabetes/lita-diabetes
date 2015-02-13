module Lita
    module Handlers
        class Diabetes < Handler
            $conversionRatio = 18.0182

            route(/(?:^|_)(\d{1,3})(?:$_)/, :convert)

            def convert(response)
                response.reply('done')
            end

            def mgdlToMmol(n)
                return (n.to_i / $conversionRatio).round(1).to_s
            end

            def mmolToMgdl(n)
                return (n.to_f * $conversionRatio).round.to_s
            end

            def mgdlToDcct(n)
                return ((n.to_i + 46.7) / 28.7)
            end

            def mgdlToIfcc(n)
                return ((mgdlToDcct(n) - 2.15) * 10.929)
            end
        end

        Lita.register_handler(Diabetes)
    end
end
