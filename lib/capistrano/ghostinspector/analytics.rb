require "capistrano/ghostinspector/analytics"
require "staccato"

module Capistrano
  module Ghostinspector
	  class Analytics
	  	def initialize(ga_property, domain)
	  		@tracker = Staccato.tracker(ga_property)
	  		$domain = domain
	  	end

	    def pushDeployment(current_revision)

			# inform GA of a new deployment
			@tracker.event(category: 'deployment', action: 'deploy', label: current_revision, non_interactive: true)

	    end

	    def pushErrors(current_revision, data)

			data['steps'].each do |step|

				if (step['passing'] == false)
					# send the errors to GA
					@tracker.event(category: 'error', action: step['error'], label: "Command: #{step['command']} - Target: #{step['target']}", non_interactive: true)
				end

			end

	    end

	    def pushData(data)
	    	
			testName = data[0]['test']['name']	    	
	    	hit = Staccato::Pageview.new(@tracker, hostname: @domain, path: testName, title: testName)
			hit.add_custom_dimension(1, testName)
			hit.track!

	    end

	  end
  end
end