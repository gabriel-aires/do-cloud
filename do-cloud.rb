require 'droplet_kit'

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
config = {}

vm_image = 'ubuntu-18-04-x64'
vm_size = 's-1vcpu-1gb'

config['active_lb']		= { name: 'neo-lb1', region: 'nyc1', image: vm_image, size: vm_size}
config['standby_lb']	= { name: 'neo-lb2', region: 'nyc3', image: vm_image, size: vm_size}
config['app_server1'] = { name: 'neo-app1', region: 'nyc1', image: vm_image, size: vm_size}
config['app_server2'] = { name: 'neo-app2', region: 'nyc3', image: vm_image, size: vm_size}

config.each do |vm, settings|
	puts "Creating machine #{vm}..."

	host_config = DropletKit::Droplet.new(
		name: settings[:name],
		region: settings[:region],
		image: settings[:image],
		size: settings[:size],
		ssh_keys: neo_keys,
		private_networking: true,
	)

	created = cloud.droplets.create host_config
	sleep 5

	host = cloud.droplets.find(id: created.id)
	host.networks.v4.each do |network|
		puts "#{network.type} ipv4:\t#{network.ip_address}"
	end

end
