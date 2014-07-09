require 'blender/discoveries/chef'
require 'blender/discoveries/serf'

module Blender
  module Discovery
    def self.get(type)
      case type.to_sym
      when :chef
        ChefDiscovery
      when :serf
        SerfDiscovery
      else
        raise 'Discovery method not sypported'
      end
    end

    def register_discovery(type, name, opts = nil)
      @registered_discoveries[name] = Discovery.get(type).new(opts)
    end

    def discover_by(name, opts)
      @registered_discoveries[name].search(opts)
    end

    def discover(type, options = {})
      search_opts = options[:search] || {}
      @global_discovery = Discovery.get(type).new(options).search(search_opts)
    end
  end
end
