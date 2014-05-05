require 'blender/drivers/ssh'
require 'blender/drivers/shellout'

module Blender
  module Driver
    def self.get(type)
      case type.to_sym
      when :ssh
        Driver::Ssh
      when :local
        Driver::ShellOut
      else
        raise ArgumentError, "Can not find driver of type '#{type.inspect}'"
      end
    end
  end
end
