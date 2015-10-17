module Capistrano
  module Ghostinspector
    def self.set_config(config)

    	giconfig = YAML::load(File.read("gi_config.yaml"))

		set :gi_api_key, giconfig["APIKEY"]

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