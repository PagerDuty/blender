require 'chef_metal'
require 'chef_metal_lxc/lxc_provisioner'

with_chef_local_server chef_repo_path: File.expand_path('../../../', __FILE__)
with_provisioner ChefMetalLXC::LXCProvisioner.new
with_provisioner_options 'template' => 'ubuntu'

{web: 3, lb: 1, db: 1}.each do |app, count|
  count.times do |n|
    machine "#{app}-#{n}" do
      recipe "blender::#{app}"
      tag app
    end
  end
end
