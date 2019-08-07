package 'docker.io'

execute "docker pull jwilder/whoami"

execute "docker run -d -p 80:8000 --name whoami -t jwilder/whoami"
