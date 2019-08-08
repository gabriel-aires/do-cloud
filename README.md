# do-cloud
Automated Cloud Provisioning using Digital Ocean's 'droplet_kit' ruby gem

## Dependencies

* ruby
* ruby-bundler
* unzip
* sudo
* wget

## Installation
The following instructions are for Ubuntu 18.04:

```
sudo -i
apt install -y ruby ruby-bundler unzip sudo wget
cd /opt
wget https://github.com/gabriel-aires/do-cloud/archive/master.zip
unzip master.zip
rm -f master.zip
mv do-cloud-master do-cloud
cd do-cloud
bundle
./do-schedule.rb
```

## Preparation
Actual usage of the scripts require an active Digital Ocean account and a personal access token, according to the available [instructions](https://www.digitalocean.com/docs/api/create-personal-access-token/)

The key should be stored in the file **/opt/do-cloud/.do-token.txt**

## Results
The cloud shoud be provisioned every weekday at 07:00 and destroyed at 19:00. The infrastructure consists of the following virtual machines:

* neo-lb1 (active load balancer, static IP enabled)
* neo-lb2 (standby load balancer for easy failover)
* neo-app1 (docker application server 1)
* neo-app2 (docker application server 2)

![Cloud Overview](https://raw.githubusercontent.com/gabriel-aires/do-cloud/master/docs/cloud-overview.png)

## Monitoring

Monitoring is immediately available through the Digital Ocean Dashboard:

![Host Monitoring](https://raw.githubusercontent.com/gabriel-aires/do-cloud/master/docs/host-monitoring.png)
