#!/usr/bin/env ruby

up_at			= "0  7    * * 1-5"
down_at		= "0  19   * * 1-5"
run_as		= " root"
up_cmd 		= "    cd /opt/do-cloud && ./do-cloud.rb < .do-token.txt &>> /var/log/cloud-up.log"
down_cmd	= "    cd /opt/do-cloud && ./do-destroy.rb < .do-token.txt &>> /var/log/cloud-down.log"
testfile	= "/opt/do-cloud/.do-crontab.txt"
message   = "Crontab installed at #{Time.now.to_s}"

if File.exist? testfile
	puts "Crontab already installed."

else

	File.open testfile, 'w' do |file|
		file.puts message
	end

	File.open "/etc/crontab", 'a' do |file|
		file.puts up_at + run_as + up_cmd
		file.puts down_at + run_as + down_cmd
	end

  puts message

end

