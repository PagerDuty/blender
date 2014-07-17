require 'blender/discoveries/chef'
require 'blender/discoveries/serf'
require 'blender/utils/refinements'

module Blender
  module Discovery
    include Blender::Utils::Refinements
    def build_discovery(type, opts = {})
      disco_klass = Blender::Discovery.const_get(camelcase(type.to_s).to_sym)
      disco_klass.new(opts)
    end

    def serf_discover(options = {})
      search_opts = options.delete(:search) || {}
      build_discovery(:serf, options).search(search_opts)
    end

    def chef_discover(options = {})
      search_opts = options.delete(:search) || {}
      build_discovery(:chef, options).search(search_opts)
    end
  end
end
