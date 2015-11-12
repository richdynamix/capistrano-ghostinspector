module Capistrano
  module Ghostinspector
    def self.getTests(test, giconfig, default)

      # Return an array of tests/suites to
      # run in ghost inspector
      array = Array.new
      if (test != nil)
        test.split(',').each do |key|
          if (giconfig.has_key?(key))
            array << giconfig[key]
          end
        end
      end

      # add any default tests or suites set by the stage
      if (default != nil)
        default.split(',').each do |key|
          if (giconfig.has_key?(key))
            if(array.include?(giconfig[key]))
              # do nothing, it already exists
            else
              array << giconfig[key]
            end            
          end
        end
      end

      return array

    end
  end
end
