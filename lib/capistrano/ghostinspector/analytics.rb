require "staccato"

module Capistrano
  module Ghostinspector
    class Analytics
      def initialize(options)
        @options = options
        @tracker = Staccato.tracker(options[:ga_property])
      end

      def pushData(type, results)

        # Lets push the deployment in GA if the configuration allows it.
        pushDeployment()

        if type == "tests"
          testname = "GI TEST - " + results["data"]["test"]["name"]

          if results["data"]["passing"] == true
            trackData(results["data"]["steps"], testname, "success")
          else
            trackData(results["data"]["steps"], testname, "error")
          end

        else

          testname = "GI TEST - " + results["testName"]

          if results["passing"] == true
            trackData(results["steps"], testname, "success")
          else
            trackData(results["steps"], testname, "error")
          end

        end

      end

      private

      def pushDeployment()

        # inform GA of a new deployment
        @action = "deploy to #{@options[:stage]}"
        current_revision = @options[:current_revision][0,7]
        previous_revision = @options[:previous_revision][0,7]
        @deployed = "Deployed revision #{current_revision} from branch #{@options[:branch]} (replacing #{previous_revision})"
        hit = Staccato::Event.new(@tracker, category: 'deployment', action: @action, label: @deployed, document_hostname: @options[:domain], document_path: @action)
        hit.add_custom_dimension(@options[:ga_custom_1], "deployment")
        hit.add_custom_dimension(@options[:ga_custom_2], "#{@options[:tickets]}")
        hit.track!

      end

      def trackData(steps, testName, type)

        if type == 'success'
          steps.each do |step|

            hit = Staccato::Event.new(@tracker, category: 'success', action: step['command'], label: step['target'], document_hostname: @options[:domain], document_path: testName)
            hit.add_custom_dimension(@options[:ga_custom_1], testName)
            hit.add_custom_dimension(@options[:ga_custom_2], "#{@options[:tickets]}")
            hit.track!

          end
          # pageView(testName)
        else
          steps.each do |step|

            if (step['passing'] == false)
              # send the errors to GA

              hit = Staccato::Event.new(@tracker, category: 'error', action: step['error'], label: "Command: #{step['command']} - Target: #{step['target']}", document_hostname: @options[:domain], document_path: testName)
              hit.add_custom_dimension(@options[:ga_custom_1], testName)
              hit.add_custom_dimension(@options[:ga_custom_2], "#{@options[:tickets]}")
              hit.track!
            end

          end
        end

      end

      def pageView(testName)

        hit = Staccato::Pageview.new(@tracker, hostname: @options[:domain], path: testName, title: testName, document_hostname: @options[:domain])
        hit.add_custom_dimension(@options[:ga_custom_1], testName)
        hit.add_custom_dimension(@options[:ga_custom_2], "#{@options[:tickets]}")
        hit.track!

      end

    end
  end
end
