
require 'lxc/extra'
require 'chef_zero/server'
require 'chef/knife/cookbook_upload'
require 'irbtools'
require 'singleton'
require 'blender'
require 'mixlib/shellout'

class Harness

  attr_reader :server
  include Singleton
  BASE_CONTAINER = 'trusty'

  def initialize
    ip = '10.0.3.1' # default lxc private bridge interface
    @server = ChefZero::Server.new(host: ip)
    Chef::Config[:chef_server_url]= "http://#{ip}:8889"
    Chef::Config[:client_key] = File.expand_path('../hendrix.pem', __FILE__)
    Chef::Config[:node_name] = 'JimHendrix'
  end

  def create_chef_environment(name, attrs = {})
    e = Chef::Environment.new
    e.name(name)
    e.default_attributes(attrs)
    e.save
  end

  def start_chef_server
    server.start_background unless server.running?
  end

  def shellout(command)
    cmd = Mixlib::ShellOut.new(command)
    cmd.run_command
    cmd
  end

  def stop
    server.stop if server.running?
  end

  def sandbox_create(app, count, opts ={})
    if opts[:base_container]
      base = opts.delete(:base_container)
    else
      base = BASE_CONTAINER
    end
    ips = []
    count.times do |number|
      name = sprintf("%s-%02d", app, number+1)
      ct = create_container(name, base)
      ips << ct.ip_addresses.first
      yield ct if Kernel.block_given?
    end
    ips
  end

  def create_container(name, base_ct)
    base = LXC::Container.new(base_ct)
    if base.running?
      base.stop
    end
    ct = LXC::Container.new(name)
    unless ct.defined?
      puts "Creating container: #{name}"
      ct = base.clone(name)
    end
    unless ct.running?
      ct.start
      # wait till ip assign
      sleep 1 while ct.ip_addresses.empty?
    end
    ct
  end

  def container(name)
    case name
    when String
      LXC::Container.new(name)
    when LXC::Container
      name
    else
      raise ArgumentError, name.inspect
    end
  end

  def lxc_execute(ct, command)
    out = ct.execute do
      cmd = Mixlib::ShellOut.new(command)
      cmd.live_stream = $stdout
      cmd.run_command
      cmd.exitstatus
    end
    if out != 0
      raise RuntimeError, "Failed to execute [#{command}]\n"
    end
    out
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

  def destroy(spec)
    spec.each do |app, count|
      count.times do |n|
        ct = LXC::Container.new(sprintf("%s-%02d", app, n+1))
        ct.stop if ct.running?
        ct.destroy if ct.defined?
      end
    end
  end

  def run_chef(ct, opts={})
    run_list = opts[:run_list]
    env = opts[:environment]
    puts "running chef on: '#{ct.name}' run_list: '#{run_list}' env:#{env}"
    args = ''
    args << " -r #{run_list}" unless run_list.nil?
    args << " -E #{env}" unless env.nil?
    lxc_execute(ct, "chef-client #{args}")
  end
end

def helper
  Harness.instance
end
