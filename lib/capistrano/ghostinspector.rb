require "capistrano/ghostinspector/version"
require "capistrano/ghostinspector/arrays"
require "capistrano/ghostinspector/api"
require "capistrano"

module Capistrano
  module Ghostinspector
    def self.load_into(config)
      config.load do
        after "deploy", "capistrano:ghostinspector:run"

        namespace :capistrano do
          namespace :ghostinspector do
            task :run, :only => { :primary => true } do

              set :giconfig = YAML::load(File.read("gi_config.yaml"))

              set :gi_api_key, giconfig["APIKEY"]

              # Get tests and suites from command line
              set :gitest, fetch(:gitest, nil)
              set :gisuite, fetch(:gisuite, nil)

              # Check if GI is enabled for this deployment (Default: true)
              set :gi_enabled, fetch(:gi_enabled, giconfig["gi_enabled"])

              # Should we rollback on failed GI tests (Default: true)
              set :rollback, fetch(:rollback, giconfig["rollback"])

              if (gi_enabled == true)

                # run each test
                Capistrano::Ghostinspector.getTests(gitest, giconfig["tests"]).each do |test|
                  puts "* * * Running Ghost Inspector Test * * *"
                  set :passing, Capistrano::Ghostinspector.executeApi("tests", test, gi_api_key, domain, rollback)
                end

                # run each suite
                Capistrano::Ghostinspector.getTests(gisuite, giconfig["suites"]).each do |suite|
                  puts "* * * Running Ghost Inspector Suite * * *"
                  set :passing, Capistrano::Ghostinspector.executeApi("suites", suite, gi_api_key, domain, rollback)
                end

                # If any test fails and the stage allows rollbacks then
                # rollback to previous version.
                if (passing == false && rollback == true)
                  puts "* * * Ghost Inspector Failed. Rolling back * * *"
                  run_locally %{cap #{stage} deploy:rollback}
                else
                  puts "* * * Ghost Inspector Complete. Deployment Complete * * *"
                end

              end
            end
          end
        end

      end
    end
  end
end


if Capistrano::Configuration.instance
  Capistrano::Ghostinspector.load_into(Capistrano::Configuration.instance)
end