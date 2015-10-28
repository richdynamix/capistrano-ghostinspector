require "capistrano"
require "capistrano/ghostinspector/version"
require "capistrano/ghostinspector/arrays"

module Capistrano
  module Ghostinspector
    def self.load_into(config)
      config.load do
        after "deploy", "ghostinspector:setup"
        after "ghostinspector:setup", "ghostinspector:run"

        gi_config = YAML::load(File.read("gi_config.yaml"))

        namespace :ghostinspector do
          desc "Setup Ghost Inspector Config"
          task :setup, :only => { :primary => true } do

            # Ghost Inspector API key
            set :gi_api_key, gi_config["APIKEY"]

            # Google Analytics Tracking Property
            set :ga_property, gi_config['ga_property']

            # Get tests and suites from command line
            set :gitest, fetch(:gitest, nil)
            set :gisuite, fetch(:gisuite, nil)

            # Check if GI is enabled for this deployment (Default: true)
            set :gi_enabled, fetch(:gi_enabled, gi_config['gi_enabled'])

            # Should we rollback on failed GI tests (Default: true)
            set :rollback, fetch(:rollback, gi_config['rollback'])

            set :branch, fetch(:branch, "default")

            set :deployed, "Deployed revision #{current_revision[0,7]} from branch #{branch} (replacing #{previous_revision[0,7]})"

          end
          
          desc "Run Ghost Inspector Tests"
          task :run, :only => { :primary => true } do

            if (fetch(:gi_enabled) == true)

              giApi = Api.new(fetch(:gi_api_key), fetch(:domain), fetch(:rollback), fetch(:ga_property))
              
              @collection = Array.new
              # run each test
              Capistrano::Ghostinspector.getTests(gitest, gi_config["tests"]).each do |test|
                puts "* * * Running Ghost Inspector Test * * *"
                set :data, giApi.executeApi("tests", test)

                items = { :passing => data[0], :results => data[1], :type =>  "tests"}
                @collection << items
              end

              # run each suite
              Capistrano::Ghostinspector.getTests(gisuite, gi_config["suites"]).each do |suite|
                puts "* * * Running Ghost Inspector Suite * * *"
                set :data, giApi.executeApi("suites", test)
                
                items = { :passing => data[0], :results => data[1], :type =>  "suites"}
                @collection << items
              end

            end

          end

          desc "Send Results to Google Analytics"
          task :sendGA, :only => { :primary => true } do

            puts "* * * Sending Data to Google Analytics * * *"
            
            options = { 
              :ga_property => fetch(:ga_property),
              :ga_custom_1 => gi_config["ga_custom_1"],
              :ga_custom_2 => gi_config["ga_custom_2"],
              :domain => fetch(:domain), 
              :deployed => fetch(:deployed), 
              :stage => fetch(:stage)
            }

            # analytics = Analytics.new(fetch(:ga_property), fetch(:domain), fetch(:deployed), fetch(:stage), gi_config)
            analytics = Analytics.new(options)

            @collection.each do |item|
              analytics.pushData(item[:type], item[:results])
            end

          end

          desc "Finalise Ghost Inspector Run"
          task :finalise_run, :only => { :primary => true } do

            set :passing, true
            @collection.each do |item|
              if item[:passing] == false
                set :passing, false
              end
            end

            # If any test fails and the stage allows rollbacks then
            # rollback to previous version.
            if (fetch(:passing) == false && fetch(:rollback) == true)
              puts "* * * Ghost Inspector Failed. Rolling back * * *"
              run_locally %{cap #{stage} deploy:rollback}
            else
              puts "* * * Ghost Inspector Complete. Deployment Complete * * *"
            end

          end

        end


        after "ghostinspector:run", "ghostinspector:sendGA"
        after "ghostinspector:sendGA", "ghostinspector:finalise_run"

      end
    end
  end
end


if Capistrano::Configuration.instance
  Capistrano::Ghostinspector.load_into(Capistrano::Configuration.instance)
end