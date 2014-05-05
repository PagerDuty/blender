require 'blender/log'
require 'blender/handlers/base'

module Blender
  class EventDispatcher
    def initialize
      @handlers = []
    end

    def register(handler)
      @handlers << handler
    end

    # Define a method that will be forwarded to all
    def self.def_forwarding_method(method_name)
      class_eval(<<-END_OF_METHOD, __FILE__, __LINE__)
        def #{method_name}(*args)
          @handlers.each {|s| s.#{method_name}(*args)}
        end
      END_OF_METHOD
    end

   (Handlers::Base.instance_methods - Object.instance_methods).each do |method_name|
      def_forwarding_method(method_name)
    end                                           
  end
end
