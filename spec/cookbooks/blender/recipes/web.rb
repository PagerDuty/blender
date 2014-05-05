package 'nginx'

service 'nginx' do
  action [:enable, :start]
end
