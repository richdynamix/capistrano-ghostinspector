require "capistrano/ghostinspector/analytics"
require 'net/https'
require 'json'

module Capistrano
  module Ghostinspector
	  module Api
	    def self.executeApi(type, test, gi_api_key, domain, rollback, ga_property, current_revision)

	    	# Determine if we should get results to 
	    	# check for any failed tests
			immediate = self.includeResults(rollback, ga_property)
			
			# Default all tests pass
			passing = true

			analytics = Analytics.new(ga_property, domain)

			# Lets push the deployment in GA if the configuration allows it.
			analytics.pushDeployment(current_revision)

			# testing only
			results = JSON.parse(File.read("gitestresults.json"))

			# puts(results)

			analytics.pushData(results['data'])

			# # Perform the API request and get the results
			# results = self.sendRequest(type, test, gi_api_key, domain, immediate)

			# Check the data returned for failed tests
			# if (rollback == true) 
			# 	passing = self.getPassing(type, results, ga_property)
			# end

			# if (passing == false && ga_property != "")
			# 	Capistrano::Ghostinspector::Analytics.pushErrors(ga_property, current_revision, results['data'])
			# end

			return passing
			
	    end

	    def self.includeResults(rollback, ga_property)
	    	# Determine if we should get results to 
	    	# check for any failed tests
			if (rollback == false && ga_property == "")
				immediate = "&immediate=1"
			else
				immediate = ""
				puts "* * * Gathering results. This could take a few minutes. * * *"
			end

			return immediate
	    end

	    def self.sendRequest(type, test, gi_api_key, domain, immediate)
	    	
	    	# execute the Ghost Inspector API call
			uri = URI("https://api.ghostinspector.com/v1/#{type}/#{test}/execute/?apiKey=#{gi_api_key}&startUrl=http://#{domain}/#{immediate}")
			data = Net::HTTP.get(uri)

			results = JSON.parse(data)

			return results
	    end

	    def self.getPassing(type, results, ga_property)
	    	
	    	if (type == "suite")
				results['data'].each do |testItem|                  
				  passing = testItem['passing']
				end
			else 
				passing = results['data']['passing']
			end

			return passing
	    	
	    end

	  end
  end
end