require 'net/https'
require 'json'

module Capistrano
  module Ghostinspector
    def self.executeApi(type, test, gi_api_key, domain, rollback)

    	# Determine if we should get results to 
    	# check for any failed tests
		if (rollback == false)
			immediate = "&immediate=1"
		else
			immediate = ""
			puts "* * * Gathering results. This could be a few minutes. * * *"
		end
		
		# Default all tests pass
		passing = true

		# execute the Ghost Inspector API call
		uri = URI("https://api.ghostinspector.com/v1/#{type}/#{test}/execute/?apiKey=#{gi_api_key}&startUrl=http://#{domain}/#{immediate}")
		data = Net::HTTP.get(uri)

		# Check the data returned for failed tests
		if (rollback == true) 
			results = JSON.parse(data)

			if (type == "suite")
				results['data'].each do |test|                  
				  passing = test['passing']
				end
			else 
				passing = results['data']['passing']
			end
		end

		return passing
		
    end
  end
end