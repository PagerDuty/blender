require 'blender/drivers/ssh'
require 'blender/drivers/shellout'
require 'blender/drivers/serf'
require 'blender/drivers/serf_multi'
require 'blender/drivers/serf_async'

module Blender
  module Driver
    def self.get(type)
      case type.to_sym
      when :ssh
        Driver::Ssh
      when :local
        Driver::ShellOut
      when :serf
        Driver::Serf
      when :serf_multi
        Driver::SerfMulti
      when :serf_async
        Driver::SerfAsync
      else
        raise ArgumentError, "Can not find driver of type '#{type.inspect}'"
      end
    end
  end
end
