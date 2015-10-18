require "capistrano/ghostinspector/analytics"
require 'net/https'
require 'json'

module Capistrano
  module Ghostinspector
    def self.executeApi(config, type, test)

    	# Determine if we should get results to 
    	# check for any failed tests
		if (rollback == false && ga_property == "")
			immediate = "&immediate=1"
		else
			immediate = ""
			puts "* * * Gathering results. This could take a few minutes. * * *"
		end
		
		# Default all tests pass
		passing = true

		# execute the Ghost Inspector API call
		uri = URI("https://api.ghostinspector.com/v1/#{type}/#{test}/execute/?apiKey=#{gi_api_key}&startUrl=http://#{domain}/#{immediate}")
		data = Net::HTTP.get(uri)

		results = JSON.parse(data)

		# Lets report the deployment in GA the configuration allows it.
		Capistrano::Ghostinspector.reportDeployment(config)


		# Check the data returned for failed tests
		if (rollback == true) 
			if (type == "suite")
				
				results['data'].each do |testItem|                  
				  passing = testItem['passing']
				end

			else 

				passing = results['data']['passing']

				if (passing == false && ga_property != "")
					Capistrano::Ghostinspector.sendErrors(config, results['data'])
				end

			end

		end

		return passing
		
    end
  end
end