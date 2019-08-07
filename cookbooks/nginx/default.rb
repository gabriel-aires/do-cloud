package 'nginx' 

remote_file "/etc/nginx/conf.d/load_balancer.conf"

service 'nginx' do
  action [:enable, :start]
end
