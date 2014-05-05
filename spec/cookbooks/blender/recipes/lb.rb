package 'haproxy'

service 'haproxy' do
  action [:enable, :start]
end
