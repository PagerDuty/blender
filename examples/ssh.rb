require_relative 'data/helper'
require 'blender'


members = helper.sandbox_create('db', 3, base_container: 'trusty')
puts members.inspect
chef_deb_url = 'https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/13.04/x86_64/chef_11.12.4-1_amd64.deb'

#Blender::Log.level = :debug

Blender.blend('install chef') do |sch|
  sch.members members
  sch.strategy :per_host
  sch.driver 'ssh' do |config|
    config[:user] = 'ubuntu'
    config[:password] = 'ubuntu'
    config[:paranoid] = false
    config[:user_known_hosts_file] = '/dev/null'
  end
  sch.task 'install wget' do |t|
    t.execute 'sudo apt-get install -y wget'
    t.not_if 'dpkg -l wget'
  end
  sch.task 'download chef' do |t|
    t.execute "sudo wget -O /opt/chef.deb -c #{chef_deb_url}"
    t.not_if 'ls -l /opt/chef.deb'
  end
  sch.task 'install chef' do |t|
    t.execute 'sudo dpkg -i /opt/chef.deb'
    t.not_if 'dpkg -l chef'
  end
  sch.task 'verify' do |t|
    t.execute '/opt/chef/bin/chef-client -v'
  end
  sch.concurrency 1
end
helper.destroy(db: 3)
