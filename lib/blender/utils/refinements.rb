module Blender
  module Utils
    module Refinements
      def camelcase(string)
        str = string.dup
        str.gsub!(/[^A-Za-z0-9_]/,'_')
        rname = nil
        regexp = %r{^(.+?)(_(.+))?$}
        mn = str.match(regexp)
        if mn
          rname = mn[1].capitalize
          while mn && mn[3]
            mn = mn[3].match(regexp)
            rname << mn[1].capitalize if mn
          end
        end
        rname
      end
    end
  end
end
