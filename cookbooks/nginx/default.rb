package 'nginx'

remote_file "/etc/nginx/conf.d/load_balancer.conf" do
  subscribes :create, "package[nginx]"
end

service 'nginx' do
  action [:enable, :start]
  subscribes :restart, "remote_file[/etc/nginx/conf.d/load_balancer.conf]"
end
