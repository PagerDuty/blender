require 'serfx'

module Blender
  module Discovery
    class SerfDiscovery
      def initialize(opts)
        @config = opts
      end
      def search(opts = {})
        tags = opts[:tags] || {}
        status = opts[:status] || 'alive'
        name = opts[:name]
        hosts = []
        Serfx.connect(@config) do |conn|
          conn.members_filtered(tags, status, name).body['Members'].map do |m|
            hosts << m['Name']
          end
        end
        hosts
      end
    end
  end
end
