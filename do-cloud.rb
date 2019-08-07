#!/usr/bin/env ruby
require 'droplet_kit'
require 'net/ssh'

#VM Configuration
vms = {}
hosts = {}
config = {}
vm_image = 'ubuntu-18-04-x64'
vm_size = 's-1vcpu-1gb'
config['active_lb']		= { name: 'neo-lb1', region: 'nyc1', image: vm_image, size: vm_size}
config['standby_lb']	= { name: 'neo-lb2', region: 'nyc1', image: vm_image, size: vm_size}
config['app_server1'] = { name: 'neo-app1', region: 'nyc1', image: vm_image, size: vm_size}
config['app_server2'] = { name: 'neo-app2', region: 'nyc1', image: vm_image, size: vm_size}

#initialize Digital Ocean client
token_file = ARGV.size == 1 ? ARGV.first : "STDIN"
token = ARGF.gets.chomp
puts "API Token read from #{token_file}. Initializing client..."

cloud = DropletKit::Client.new(
	access_token: 	token,
	open_timeout: 	60,
	timeout:	120,
)

#SSH key-pair generation
sshkey_file = "#{Dir.home}/.ssh/neocloud_id_rsa"

if File.exists? sshkey_file
	puts "Using existing ssh key at #{sshkey_file}"
else
	puts "Generating new ssh key-pair..."
	system "ssh-keygen -t rsa -C neocloud -f #{sshkey_file} -N ''"
end

#SSH public key upload
pubkey_content = File.read "#{sshkey_file}.pub"
pubkey = DropletKit::SSHKey.new name: "neokey", public_key: pubkey_content
key_uploaded = cloud.ssh_keys.all.any? { |key| key.name == "neokey" }

if key_uploaded
	puts "SSH key already uploaded to Digital Ocean"
else
	puts "Uploading key to Digital Ocean Account"
	cloud.ssh_keys.create pubkey
end

neo_keys = cloud.ssh_keys.all.select { |key| key.name == "neokey" }.map { |key| key.fingerprint}

#Provision Infrastructure
config.each do |role, settings|
  hostname = settings[:name]
	puts "Creating machine #{hostname} (#{role})..."

	host_config = DropletKit::Droplet.new(
		name: hostname,
		region: settings[:region],
		image: settings[:image],
		size: settings[:size],
		ssh_keys: neo_keys,
		private_networking: true,
		monitoring: true,
	)

	created = cloud.droplets.create host_config
  puts "ID: #{created.id}"
	sleep 5

	host = cloud.droplets.find(id: created.id)
	host.networks.v4.each do |network|

  	puts "#{network.type} ipv4:\t#{network.ip_address}"
    if network.type == 'public'
      vms[hostname] = network.ip_address
    else
      hosts[hostname] = network.ip_address
    end

	end

end

#Wait for cloud setup
sleep 60

vms.each do |hostname, public_addr|

	puts "Testing ssh connection for host #{hostname} (#{public_addr})..."
  host_key = `ssh-keyscan -H "#{public_addr}"`
	File.open "#{Dir.home}/.ssh/known_hosts", 'a' do |file|
		file.puts host_key
	end

	puts "updating hosts file, installing dependencies"
	Net::SSH.start(public_addr, 'root', keys: [sshkey_file]) do |ssh|

		hosts.each do |name, ip|
			ssh.exec! "echo #{ip} #{name} >> /etc/hosts" if name != hostname
		end

    ssh.exec! "apt update"
		ssh.exec! "apt install ruby -y"
		puts ssh.exec! "gem install itamae -q"
	end

end
