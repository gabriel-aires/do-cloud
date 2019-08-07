package 'nginx'

remote_file "/etc/nginx/conf.d/load_balancer.conf"

file "/etc/nginx/sites-enabled/default" do
  action :delete
end

service 'nginx' do
  action [:enable, :start]
end

execute "systemctl restart nginx"
