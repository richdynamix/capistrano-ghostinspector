require 'json'

module Capistrano
  module Ghostinspector
    def self.webservice(type, test, gi_api_key, domain, rollback)

		if (rollback == false)
			immediate = "&immediate=1"
		else
			immediate = ""
		end
		
		passing = true

		run_locally %{curl "https://api.ghostinspector.com/v1/#{type}/#{test}/execute/?apiKey=#{gi_api_key}&startUrl=http://#{domain}/#{immediate}"  > gitestresults.json}
		


		results = JSON.parse(File.read("gitestresults.json"))

		if (type = "suite")
			results['data'].each do |test|                  
			  passing = test['passing']
			end
		else 
			passing = results['data']['passing']
		end
		

    end
  end
end