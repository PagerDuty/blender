require 'blender/exceptions'
require 'blender/tasks/executer'
module Blender
  module TaskFactory
    def self.get(type)
      case type
      when :executer
        Blender::Task::Executer
      else
        raise Exceptions::UnknownTask, "Dont know how to execute task '#{type}'"
      end
    end
  end
end
