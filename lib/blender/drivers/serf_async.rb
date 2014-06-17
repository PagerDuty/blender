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
        Log.debug("Serf RPC address #{@config[:host]}:#{@config[:port]}")
        begin
          start(command)
          until not_running?(command)
            Log.debug('Job still running. sleeping for 10s')
            sleep 10
          end
          reap_responses = reap(command)
          ExecOutput.new(0, JSON.generate({sucess: true}))
        rescue Exceptions::SerfAsyncJobError => e
          ExecOutput.new(-1, e.to_s)
        end
      end

      def not_running?(command)
        checks = []
        running = false
        Serfx.connect(host: @config[:host], port: @config[:port]) do |conn|
          conn.query(command, 'check', 'FilterNodes'=> [@current_host], 'Timeout'=> 20*1e9.to_i) do |event|
            checks <<  event
          end
        end
        if checks.empty?
          raise Exceptions::SerfAsyncJobError, 'Failes to check status of job, no response received'
        end
        JSON.parse(checks.first['Payload'])['status'] != 'running'
      end

      def reap(command)
        responses = []
        Serfx.connect(host: @config[:host], port: @config[:port]) do |conn|
          conn.query(command, 'reap', 'FilterNodes'=> [@current_host], 'Timeout'=> 20*1e9.to_i) do |event|
            responses <<  event
          end
        end
        raise Exceptions::SerfAsyncJobError, 'Failes to reap job: No response received' if responses.empty?
        unless responses.first['Payload'].strip == 'success'
          raise ExecOutput::SerfAsyncJobError,  "Failed to reap job: #{responses.first.inspect}"
        end
      end

      def start(command)
        Log.debug("Invoking serf query '#{command}' with payload 'start' against #{@current_host}")
        responses = []
        Serfx.connect(host: @config[:host], port: @config[:port]) do |conn|
          conn.query(command, 'start', 'FilterNodes'=> [@current_host], 'Timeout'=> 20*1e9.to_i) do |event|
            responses <<  event
          end
        end
        raise Exceptions::SerfAsyncJobError, 'No response received' if responses.empty?
        unless responses.first['Payload'].strip == 'success'
          raise Exceptions::SerfAsyncJobError,  "Failed to reap job: #{responses.first.inspect}"
        end
      end
    end
  end
end
