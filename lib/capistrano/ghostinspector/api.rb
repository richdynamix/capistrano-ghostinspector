require 'net/https'
require 'json'

module Capistrano
  module Ghostinspector
    class Api

      def initialize(gi_api_key, domain, rollback, ga_enabled)
        @apiKey = gi_api_key
        @domain = domain
        @rollback = rollback
        @ga_enabled = ga_enabled

        # Determine if we should get results to
        # check for any failed tests
        @immediate = includeResults()
      end


      def executeApi(type, test)

        # Default all tests pass
        passing = true

        # ------ TESTING ONLY ------
        # results = JSON.parse(File.read("gitestresults.json"))
        # results = JSON.parse(File.read("suiteresults.json"))
        # ------ TESTING ONLY ------

        # # Perform the API request and get the results
        results = sendRequest(type, test)

        # Check the data returned for failed tests
        if (@rollback == true)
          passing = getPassing(type, results)
        end

        data = Array.new
        data << passing
        data << results

        return data

      end

      private

      def includeResults()

        # Determine if we should get results to
        # check for any failed tests
        if (@rollback == false && @ga_enabled == false)
          immediate = "&immediate=1"
        else
          immediate = ""
          puts "* * * Gathering results. This could take a few minutes. * * *"
        end

        return immediate
      end

      def sendRequest(type, test)
        uri = URI("https://api.ghostinspector.com/v1/#{type}/#{test}/execute/?apiKey=#{@apiKey}#{@immediate}")

        if (@domain != nil)
            uri.query = [uri.query, "startUrl=http://#{@domain}/"].compact.join('&')
        end

        Net::HTTP.start(uri.host, uri.port,
        :use_ssl => uri.scheme == 'https') do |http|
          request = Net::HTTP::Get.new uri
          http.read_timeout = 600
          @response = http.request request
        end

        results = JSON.parse(@response.body)

        return results
      end

      def getPassing(type, results)

        if (type == "suites")
          results["data"].each do |testItem|
            passing = testItem["passing"]
          end
        else
          passing = results["data"]["passing"]
        end

        return passing

      end

    end
  end
end
