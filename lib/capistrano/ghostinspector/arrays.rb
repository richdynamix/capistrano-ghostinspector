module Capistrano
  module Ghostinspector
    def self.getTests(test, giconfig)

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

		return array

    end
  end
end