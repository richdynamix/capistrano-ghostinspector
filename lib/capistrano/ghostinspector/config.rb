require "capistrano/ghostinspector/analytics"

module Capistrano
  module Ghostinspector
    def self.configure(config)
    	config.load do

	    	namespace :capistrano do
	          namespace :ghostinspector do
	            task :configure, :only => { :primary => true } do

					set :giconfig, YAML::load(File.read("gi_config.yaml"))

					# Ghost Inspector API key
					set :gi_api_key, giconfig["APIKEY"]

					# Google Analytics Tracking Property
					set :ga_property, giconfig["ga_property"]

					# Get tests and suites from command line
					set :gitest, fetch(:gitest, nil)
					set :gisuite, fetch(:gisuite, nil)

					# Check if GI is enabled for this deployment (Default: true)
					set :gi_enabled, fetch(:gi_enabled, giconfig["gi_enabled"])

					# Should we rollback on failed GI tests (Default: true)
					set :rollback, fetch(:rollback, giconfig["rollback"])

					end
				end
			end
			
		end

    end
  end
end