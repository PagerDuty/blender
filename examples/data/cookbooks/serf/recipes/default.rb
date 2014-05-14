
serf_url = 'https://dl.bintray.com/mitchellh/serf/0.6.0_linux_amd64.zip'
members = search(:node, 'name:serf-*')
joinees =  members.map{|node| "-join=#{node.ipaddress}"}.join(' ')
handlers = ' -event-handler=/opt/serf/handlers/command'
serf_gem_path = ::File.join(Chef::Config[:file_cache_path], 'serfx-0.0.1.gem')
start_command = 'daemon --stdout=/opt/serf/log/stdout --stderr=/opt/serf/log/stderr'
start_command << " --name=serf -- /opt/serf/bin/serf agent -rpc-addr=0.0.0.0:7373 #{joinees} #{handlers}"
Chef::Log.info(start_command)

package 'unzip'
package 'daemon'

user 'serf' do
  system true
end
directory '/opt/serf' do
  owner 'serf'
  group 'serf'
  mode 0644
end

%w{handlers bin zips log state lock}.each do |d|
  directory "/opt/serf/#{d}" do
    owner 'serf'
    group 'serf'
    mode 0644
  end
end

cookbook_file '/opt/serf/handlers/command' do
  owner 'serf'
  group 'serf'
  mode 0755
  source 'command.rb'
end

package 'build-essential'

cookbook_file serf_gem_path do
  source 'serfx-0.0.1.gem'
end

gem_package 'serfx' do
  gem_binary '/opt/chef/embedded/bin/gem'
  source serf_gem_path
end

remote_file '/opt/serf/zips/serf.zip' do
  source serf_url
  notifies :run, 'execute[unpack_serf]', :immediately
end

execute 'unpack_serf' do
  command 'unzip /opt/serf/zips/serf.zip -d /opt/serf/bin'
  action :nothing
end

execute 'start_serf' do
  command start_command
  not_if 'daemon -n serf --running'
end
