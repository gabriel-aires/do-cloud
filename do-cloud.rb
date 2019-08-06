require 'droplet_kit'

sshkey_file = "#{Dir.home}/.ssh/neocloud_id_rsa"
token_file = ARGV.size == 1 ? ARGV.first : "STDIN"
token = ARGF.gets.chomp
puts "API Token read from #{token_file}"
puts "-----------------------------"
puts token

cloud = DropletKit::Client.new(
	access_token: 	token,
	open_timeout: 	60,
	timeout:	120,
)

if File.exists? sshkey_file
	puts "Using existing ssh key at #{sshkey_file}"
else
	puts "Generating new ssh key-pair..."
	system "ssh-keygen -t rsa -C neocloud -f #{sshkey_file} -N ''"
end

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
template = DropletKit::Droplet.new(
	name: 'neo',
       	region: 'nyc3',
       	image: 'ubuntu-18-04-x64',
       	size: 's-1vcpu-1gb',
	ssh_keys: neo_keys,
)

puts "Creating machine from template..."
vm1 = cloud.droplets.create template
