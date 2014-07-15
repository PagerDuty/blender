require 'serfx'
require 'blender/exceptions'
require 'blender/log'
require 'blender/drivers/base'
require 'blender/drivers/serf'
require 'json'
require 'pry'

module Blender
  module Driver
    class SerfAsync < Serf
      def raw_exec(command)
        command.payload = 'start'
        start_responses = serf_query(command)
        loop do
          sleep(@config[:check_interval])
          break if command_finished?(command, start_responses)
        end
        ExecOutput.new(exit_status(responses), responses.inspect, '')
      end

      def command_finished?(command, start_responses)
        cmd = command.dup.tap{|c|c.payload = 'check'}
        check_responses = serf_query(cmd)
      end

      def reap_command?(command, start_responses)
        cmd = command.dup.tap{|c|c.payload = 'reap'}
        check_responses = serf_query(comd)
      end

      private
      def default_config
        super.merge(check_interval: 60)
      end
    end
  end
end
