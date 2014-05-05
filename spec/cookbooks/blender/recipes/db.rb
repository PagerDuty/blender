package 'mysql-server'

service 'mysql' do
  action [:enable, :start]
end
