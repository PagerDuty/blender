
require 'lxc/extra'
require 'chef_zero/server'
require 'chef/knife/cookbook_upload'
require 'irbtools'
require 'singleton'
require 'blender'

class Harness

  CHEF_CONTAINER = 'chef'

  include Singleton

  attr_reader :server

  def initialize
    ip = '10.0.3.1' # default lxc private bridge interface
    @server = ChefZero::Server.new(host: ip)
    Chef::Config[:chef_server_url]= "http://#{ip}:8889"
    Chef::Config[:client_key] = File.expand_path('../hendrix.pem', __FILE__)
    Chef::Config[:node_name] = 'JimHendrix'
  end

  def start
    server.start_background unless server.running?
    upload_cookbooks
  end

  def stop
    server.stop if server.running?
  end

  def chef_cluster(spec, run_list)
    start
    base = LXC::Container.new(CHEF_CONTAINER)
    unless base.defined?
      puts 'creating base chef container'
      base.create('download', nil, 0, %w{-d ubuntu -r trusty -a amd64})
      base.start
      sleep 5
      install_chef(base)
    end
    if base.running?
      base.stop
    end
    spec.each do |app, count|
      count.times do |n|
        name = sprintf("%s-%02d", app, n)
        ct = LXC::Container.new(name)
        unless ct.defined?
          ct = base.clone(name)
        end
        unless ct.running?
          ct.start
          sleep 5
          puts ct.execute{`chef-client`}
        end
        run_chef(ct, run_list)
      end
    end
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

  def install_chef(ct)
    data = File.read(File.expand_path('../hendrix.pem', __FILE__))
    chef_deb_url = 'https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/13.04/x86_64/chef_11.12.4-1_amd64.deb'
    ct.execute do
      FileUtils.mkdir_p '/etc/chef'
      File.open('/etc/chef/client.rb', 'w') do |f|
        f.puts('chef_server_url "http://10.0.3.1:8889"')
      end
      File.open('/etc/chef/client.pem', 'w') do |f|
        f.write(data)
      end
    end
    puts ct.execute { `apt-get install wget -y`}
    puts ct.execute { `wget -O /opt/chef.deb -c #{chef_deb_url}`}
    puts ct.execute { `dpkg -i /opt/chef.deb`}
  end

  def run_chef(ct, run_list)
    puts ct.execute { `env -i /opt/chef/bin/chef-client -r #{run_list}`}
  end
end

def helper
  Harness.instance
end
