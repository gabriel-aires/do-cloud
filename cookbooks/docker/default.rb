package 'docker.io'

execute "docker pull jwilder/whoami" do
  subscribes :run, "package[docker.io]"
end

execute "docker run -d -p 8080:8080 --name whoami -t jwilder/whoami" do
  subscribes :run, "execute[docker pull jwilder/whoami]"
  not_if "pgrep -f docker-proxy > /dev/null"
end
