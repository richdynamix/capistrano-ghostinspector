require "capistrano/ghostinspector/version"
require "capistrano/ghostinspector/arrays"
require "capistrano"
require 'json'

module Capistrano
  module Ghostinspector
    def self.load_into(config)
      config.load do
        after "deploy", "capistrano:ghostinspector:run"

        namespace :capistrano do
          namespace :ghostinspector do
            task :run, :only => { :primary => true } do

              giconfig = YAML::load(File.read("gi_config.yaml"))

              set :gi_api_key, giconfig["APIKEY"]

              # Get tests and suites from command line
              set :gitest, fetch(:gitest, nil)
              set :gisuite, fetch(:gisuite, nil)

              # Check if GI is enabled for this deployment (Default: true)
              set :gi_enabled, fetch(:gi_enabled, giconfig["gi_enabled"])

              # Should we rollback on failed GI tests (Default: true)
              set :rollback, fetch(:rollback, giconfig["rollback"])
  
              test_run = Capistrano::Ghostinspector.tests_array(gitest, giconfig["tests"])
              suite_run = Capistrano::Ghostinspector.tests_array(gisuite, giconfig["suites"])

              # Get array of tests to run
              # test_run = Array.new
              # if (gitest != nil)
              #   gitest.split(',').each do |key|
              #     if (giconfig["tests"].has_key?(key))
              #       test_run << giconfig["tests"][key] 
              #     end 
              #   end
              # end

              # # Get array of suites to run
              # suite_run = Array.new
              # if (gisuite != nil)
              #   gisuite.split(',').each do |key|
              #     if (giconfig["suites"].has_key?(key))
              #       suite_run << giconfig["suites"][key] 
              #     end 
              #   end
              # end

              if (gi_enabled == true)

                set :passing, true

                if (rollback == false)
                  set :immediate, "&immediate=1"
                else
                  set :immediate, ""
                end

                # run each test
                test_run.each do |test|

                  puts "* * * Running Ghost Inspector Test * * *"

                  # run_locally %{curl "https://api.ghostinspector.com/v1/tests/#{test}/execute/?apiKey=#{gi_api_key}&startUrl=http://#{domain}/#{immediate}"  > gitestresults.json}
                  # results = JSON.parse(File.read("gitestresults.json"))
                  # set :passing, results['data']['passing']
                end

                # run each suite
                suite_run.each do |suite|

                  puts "* * * Running Ghost Inspector Suite * * *"

                  # run_locally %{curl "https://api.ghostinspector.com/v1/suites/#{suite}/execute/?apiKey=#{gi_api_key}&startUrl=http://#{domain}/#{immediate}" > gitestresults.json}
                  # results = JSON.parse(File.read("gitestresults.json"))
                  
                  # results['data'].each do |test|                  
                  #   set :passing, test['passing']
                  # end
                end

                # If any test fails and the stage allows rollbacks then
                # rollback to previous version.
                if (passing == false && rollback == true)
                  puts "* * * Ghost Inspector Failed. Rolling back * * *"
                  run_locally %{cap #{stage} deploy:rollback}
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