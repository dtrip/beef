#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe 'BeEF API Rate Limit' do

	before(:all) do
		# Note: rake spec passes --patterns which causes BeEF to pickup this argument via optparse. I can't see a better way at the moment to filter this out. Therefore ARGV=[] for this test.
		ARGV = []
		@config = BeEF::Core::Configuration.instance
		@config.set('beef.credentials.user', "beef")
		@config.set('beef.credentials.passwd', "beef")
		http_hook_server = BeEF::Core::Server.instance
		http_hook_server.prepare
		@pids = fork do
			BeEF::API::Registrar.instance.fire(BeEF::API::Server, 'pre_http_start', http_hook_server)
		end
		@pid = fork do
			http_hook_server.start
		end
		# wait for server to start
		sleep 1
	end
    # wait for server to start
  
  	after(:all) do
	
	 Process.kill("KILL",@pid)
	 Process.kill("KILL",@pids)
	
 	end

	it 'adheres to auth rate limits' do
		passwds = (1..9).map { |i| "broken_pass"}
		passwds.push BEEF_PASSWD
		apis = passwds.map { |pswd| BeefRestClient.new('http', ATTACK_DOMAIN, '3000', BEEF_USER, pswd) }
		l = apis.length
		#If this is failing with expect(test_api.auth()[:payload]["success"]).to be(true) expected true but received nil
		#make sure in config.yaml the password = BEEF_PASSWD, which is currently 'beef'
		(0..2).each do |again|      # multiple sets of auth attempts
		  # first pass -- apis in order, valid passwd on 9th attempt
		  # subsequent passes apis shuffled
		  puts "speed requesets"    # all should return 401
		  (0..50).each do |i|
			# t = Time.now()
			#puts "#{i} : #{t - t0} : #{apis[i%l].auth()[:payload]}"
			test_api = apis[i%l]
			expect(test_api.auth()[:payload]).to eql("401 Unauthorized") # all (unless the valid is first 1 in 10 chance)
			# t0 = t
		  end
		  # again with more time between calls -- there should be success (1st iteration)
		  puts "delayed requests"
		  (0..(l*2)).each do |i|
			# t = Time.now()
			#puts "#{i} : #{t - t0} : #{apis[i%l].auth()[:payload]}"
			test_api = apis[i%l]
			if (test_api.is_pass?(BEEF_PASSWD))
				expect(test_api.auth()[:payload]["success"]).to be(true) # valid pass should succeed
			else
				expect(test_api.auth()[:payload]).to eql("401 Unauthorized")
			end
			sleep(0.5)
			# t0 = t
		  end
		  apis.shuffle! # new order for next iteration
		  apis = apis.reverse if (apis[0].is_pass?(BEEF_PASSWD)) # prevent the first from having valid passwd
		end                         # multiple sets of auth attempts
	end
 
end
