require 'blender/scheduling_strategies/default'
require 'blender/exceptions'

module Blender
  module SchedulingStrategy
    def self.get(strategy)
      case strategy
      when String, Symbol
        klass = camelcase(strategy.to_s).to_sym
        Blender::SchedulingStrategy.const_get(klass).new
      when SchedulingStrategy
        strategy.new
      else
        raise Exceptions::UnknownSchedulingStrategy, strategy.inspect
      end
    end

    def self.camelcase(string)
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
