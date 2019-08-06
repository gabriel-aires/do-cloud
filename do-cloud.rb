token_file = ARGV.size == 1 ? ARGV.first : "STDIN"
token = ARGF.gets.chomp
puts "Token read from #{token_file}"
puts "-----------------------------"
puts token

require 'droplet_kit'
cloud = DropletKit::Client.new(
	access_token: 	token,
	open_timeout: 	60,
	timeout:	120,
)


template = DropletKit::Droplet.new(
	name: 'neo1',
       	region: 'nyc3',
       	image: 'ubuntu-18-04-x64',
       	size: 's-1vcpu-1gb',
)

vm1 = cloud.droplets.create template
puts vm1.name
puts vm1.id
