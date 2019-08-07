#!/usr/bin/env ruby
require 'droplet_kit'

#list of hosts to be destroyed
hosts = ['neo-lb1', 'neo-lb2', 'neo-app1', 'neo-app2']

#initialize Digital Ocean client
token_file = ARGV.size == 1 ? ARGV.first : "STDIN"
token = ARGF.gets.chomp
puts "API Token read from #{token_file}. Initializing client..."

cloud = DropletKit::Client.new(
	access_token: 	token,
	open_timeout: 	60,
	timeout:	120,
)

#destroy infrastructure
destroy_ids = cloud.droplets.all.select { |droplet| hosts.include? droplet.name }.map { |vm| vm.id }
destroy_ids.each do |id|
	puts "Removing machine #{id}"
	cloud.droplets.delete id: id
end
