require 'net/https'
require 'json'

module Capistrano
  module Ghostinspector
	  class Api

	  	def initialize(gi_api_key, domain, rollback, ga_property)
	  		@apiKey = gi_api_key
	  		@domain = domain
	  		@rollback = rollback
	  		@ga_property = ga_property

	  		# Determine if we should get results to 
	    	# check for any failed tests
			@immediate = includeResults()
	  	end


	    def executeApi(type, test)
			
			# Default all tests pass
			passing = true

			# testing only
			results = JSON.parse(File.read("gitestresults.json"))
			# results = JSON.parse(File.read("suiteresults.json"))

			# # Perform the API request and get the results
			# results = sendRequest(type, test)

			# Check the data returned for failed tests
			if (@rollback == true) 
				passing = getPassing(type, results)
			end

			data = Array.new
			data << passing
			data << results

			return data
			
	    end

	    private

	    def includeResults()

	    	# Determine if we should get results to 
	    	# check for any failed tests
			if (@rollback == false && @ga_property == "")
				immediate = "&immediate=1"
			else
				immediate = ""
				puts "* * * Gathering results. This could take a few minutes. * * *"
			end

			return immediate
	    end

	    def sendRequest(type, test)
	    	
	    	# execute the Ghost Inspector API call
			uri = URI("https://api.ghostinspector.com/v1/#{@type}/#{@test}/execute/?apiKey=#{@apiKey}&startUrl=http://#{@domain}/#{@immediate}")
			data = Net::HTTP.get(uri)

			results = JSON.parse(data)

			return results
	    end

	    def getPassing(type, results)

	    	if (type == "suite")
				results["data"].each do |testItem|                  
				  passing = testItem["passing"]
				end
			else 
				passing = results["data"][0]["passing"]
			end

			return passing
	    	
	    end

	  end
  end
end