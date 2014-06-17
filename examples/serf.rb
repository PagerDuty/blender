require_relative 'data/helper'
require 'blender'
require 'pry'

default_config = {
    rpc_addr: "",
    keyring_file:'/opt/serf/keyring',
    start_join: [],
    event_handlers: [
      'query:long_bash=/opt/serf/handlers/task.rb', 
      'query:metadata=/opt/serf/handlers/metadata'
    ]
  }

count = 7
#Blender::Log.level = :debug
start_join = []
helper.sandbox_create('serf', count, base_container: 'serf') do |ct|
  ip = ct.ip_addresses.first
  config = default_config.merge(
    rpc_addr: "#{ip}:7373",
    start_join: start_join
    )
  metadata = {name: ct.name, ipaddress: ip, create_time: Time.now.to_s}
  ct.execute do
    File.open('/etc/serf.json', 'w') do |f|
      f.write(JSON.pretty_generate(config))
    end
    File.open('/opt/serf/meta.json', 'w') do |f|
      f.write(JSON.pretty_generate(metadata))
    end
    `/etc/init.d/serf restart`
    sleep 4
  end
  start_join << ip
end

members = Array.new(count){|n| "serf-0#{n+1}"}

Blender.blend('metadata') do |sch|
  sch.members members
  sch.strategy :per_task
  sch.driver 'serf' do |config|
    config[:host] = helper.container('serf-01').ip_addresses.first
    config[:port] = 7373
  end
  sch.task 'metadata ipaddress' do |t|
  end
end

Blender.blend('metadata') do |sch|
  sch.members members
  sch.strategy :per_task
  sch.driver 'serf_multi' do |config|
    config[:host] = helper.container('serf-01').ip_addresses.first
    config[:port] = 7373
  end
  sch.task 'metadata ipaddress'
end

Blender.blend('long running task') do |sch|
  sch.members members
  sch.driver 'serf_async' do |config|
    config[:host] = helper.container('serf-01').ip_addresses.first
    config[:port] = 7373
  end
  sch.task 'long_bash'
#  sch.concurrency(5)
end

helper.destroy(serf: 2)
