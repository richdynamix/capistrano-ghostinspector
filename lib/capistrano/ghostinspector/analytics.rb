require "capistrano/ghostinspector/analytics"
require "staccato"

module Capistrano
  module Ghostinspector
	  module Analytics
	    def self.pushDeployment(ga_property, current_revision)

	    	tracker = Staccato.tracker(ga_property)

			# inform GA of a new deployment
			tracker.event(category: 'deployment', action: 'deploy', label: current_revision, non_interactive: true)

	    end

	    def self.pushErrors(ga_property, current_revision, data)

			# send the errors to GA

			tracker = Staccato.tracker(ga_property)

			puts(data)

	    end

	  end
  end
end