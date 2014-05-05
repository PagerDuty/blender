
require 'lxc/extra'
require 'chef_zero/server'
require 'chef/knife/cookbook_upload'
require 'irbtools'
require 'singleton'
require 'blender'

class Harness

  include Singleton

  attr_reader :server

  def initialize
    ip = '10.0.3.1' # default lxc private bridge interface
    @server = ChefZero::Server.new(host: ip)
    Chef::Config[:chef_server_url]= "http://#{ip}:8889"
    Chef::Config[:client_key] = File.expand_path('../data/hendrix.pem', __FILE__)
    Chef::Config[:node_name] = 'JimHendrix'
  end

  def start
    server.start_background unless server.running?
    upload_cookbooks
  end

  def stop
    server.stop if server.running?
  end

  def upload_cookbooks
    cookbook_dir = File.expand_path('../cookbooks/', __FILE__)
    Chef::Knife::CookbookUpload.load_deps
    plugin = Chef::Knife::CookbookUpload.new
    Chef::Log.warn("Cookbook path: #{cookbook_dir}")
    plugin.config[:cookbook_path] = cookbook_dir
    plugin.config[:all] = true
    plugin.run
  end

# create_lxc_cluster web: 2 -> web-01, web-02
  def cluster_up(spec)
    ips = Hash.new{|h,k| h[k] = []}
    spec.each do |app, count|
      count.times do |n|
        ct = LXC::Container.new(sprintf("%s-%02d", app, n))
        unless ct.defined?
          ct.create('download', nil, 0, %w{-d ubuntu -r trusty -a amd64})
        end
        unless ct.running?
          ct.start
          sleep 10
        end
        ips[app] << ct.ip_addresses.first
      end
    end
    ips
  end

  def cluster_down(spec)
    spec.each do |app, count|
      count.times do |n|
        ct = LXC::Container.new(sprintf("%s-%02d", app, n))
        ct.stop if ct.running?
        ct.destroy if ct.defined?
      end
    end
  end
end

def helper
  Harness.instance
end
