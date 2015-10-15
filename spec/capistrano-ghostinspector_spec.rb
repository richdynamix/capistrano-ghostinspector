require 'spec_helper'
require 'capistrano'

describe Richdynamix::Ghostinspector, "loaded into a configuration" do
	before do
		@configuration = Capistrano::Configuration.new
		Richdynamix::Ghostinspector.load_into(@configuration)
		@configuration.set :gitest, 'home'
	end

	describe 'run' do

	    it "should define tests" do
			@configuration.fetch(:gitest).should == 'home'
		end

	end

	before do
		@configuration.set :gitest, 'home'
	end


	it "performs richdynamix:ghostinspector:run after deploy" do
		@configuration.should callback('richdynamix:ghostinspector:run').after('deploy')
	end

end