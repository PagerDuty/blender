
module Blender
  module Discovery
    def discover(type, options = {})
      case type
      when :chef
        chef_discovery(options)
      when :serf
      else
        raise 'Discovery method not sypported'
      end
    end

    def chef_discovery(options)
      require 'chef/search/query'
      if options[:config_file]
        Chef::Config.from_file options[:config_file]
      end

      if options[:node_name]
        Chef::Config[:node_name] = options[:node_name]
      end

      if options[:client_key]
        Chef::Config[:client_key] = options[:client_key]
      end
      q = Chef::Search::Query.new
      search_term = options[:search] || '*:*'
      attribute = options[:attribute] || 'fqdn'
      res = q.search(:node, search_term)
      res.first.collect{|n| node_attribute(n, attribute)}
    end

    private
    def node_attribute(data, nested_value_spec)
      nested_value_spec.split(".").each do |attr|
        if data.nil?
          nil # don't get no method error on nil
        elsif data.respond_to?(attr.to_sym)
          data = data.send(attr.to_sym)
        elsif data.respond_to?(:[])
          data = data[attr]
        else
          data = begin
            data.send(attr.to_sym)
          rescue NoMethodError
            nil
          end
        end
      end
      ( !data.kind_of?(Array) && data.respond_to?(:to_hash) ) ? data.to_hash : data
    end
  end
end
