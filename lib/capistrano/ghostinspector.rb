require "capistrano"
require "capistrano/ghostinspector/version"
require "capistrano/ghostinspector/arrays"
require "capistrano/ghostinspector/api"
require "capistrano/ghostinspector/analytics"

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

            if gi_config.has_key?("ga_custom_1")
              set :ga_custom_1, gi_config["ga_custom_1"]
            else
              set :ga_custom_1, "1"
            end

            if gi_config.has_key?("ga_custom_2")
              set :ga_custom_2, gi_config["ga_custom_2"]
            else
              set :ga_custom_2, "2"
            end

            if gi_config.has_key?("jira_project_code")
              set :jira_project_code, gi_config["jira_project_code"]
            else
              set :jira_project_code, "GHOST"
            end

            # Get tests and suites from command line
            set :gitest, fetch(:gitest, nil)
            set :gisuite, fetch(:gisuite, nil)

            # Check if GI is enabled for this deployment (Default: true)
            set :gi_enabled, fetch(:gi_enabled, gi_config['gi_enabled'])

            # Should we rollback on failed GI tests (Default: true)
            set :rollback, fetch(:rollback, gi_config['rollback'])
          end
          
          desc "Run Ghost Inspector Tests"
          task :run, :only => { :primary => true } do

            if (fetch(:gi_enabled) == true)

              giApi = Api.new(fetch(:gi_api_key), fetch(:domain), fetch(:rollback), fetch(:ga_property))
              
              @collection = Array.new
              # run each test
              Capistrano::Ghostinspector.getTests(fetch(:gitest), gi_config["tests"]).each do |test|
                puts "* * * Running Ghost Inspector Test * * *"
                set :data, giApi.executeApi("tests", test)

                items = { :passing => data[0], :results => data[1], :type =>  "tests"}
                @collection << items
              end

              # run each suite
              Capistrano::Ghostinspector.getTests(fetch(:gisuite), gi_config["suites"]).each do |suite|
                puts "* * * Running Ghost Inspector Suite * * *"
                set :data, giApi.executeApi("suites", suite)

                data[1]["data"].each do |test|
                  items = { :passing => test["passing"], :results => test, :type =>  "suites"}
                  @collection << items
                end

              end

            end

          end

          desc "Send Results to Google Analytics"
          task :sendGA, :only => { :primary => true } do

            puts "* * * Sending Data to Google Analytics * * *"

            jira_project_code = fetch(:jira_project_code)

            log = capture(
              "cd #{current_path} && git log #{previous_revision[0,7]}..#{current_revision[0,7]} --format=\"%s\" | grep -oh '#{jira_project_code}-[0-9]\\+' | sort | uniq"
            )

            options = { 
              :ga_property => fetch(:ga_property),
              :ga_custom_1 => fetch(:ga_custom_1),
              :ga_custom_2 => fetch(:ga_custom_2),
              :domain => fetch(:domain), 
              :current_revision => fetch(:current_revision),
              :previous_revision => fetch(:previous_revision),
              :branch => fetch(:branch, "default"),
              :stage => fetch(:stage),
              :tickets => Capistrano::Ghostinspector.getTickets(log)
            }

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


    def self.getTickets(log)

        tickets = ""
        log.each_line do |line|
            line.delete!('";')
            line.strip!
            line.gsub!("'", '\u0027')
            tickets = "#{tickets}, #{line}"
        end

        if (tickets.to_s == "")
            tickets = "None"
        else
            tickets[0] = ''
        end

        return tickets

    end


  end
end


if Capistrano::Configuration.instance
  Capistrano::Ghostinspector.load_into(Capistrano::Configuration.instance)
end