require "capistrano/ghostinspector/analytics"

module Capistrano
  module Ghostinspector
    def self.reportDeployment(config)

		# inform GA of a new deployment


    end

    def self.sendErrors(config, data)

		# send the errors to GA

    end

  end
end