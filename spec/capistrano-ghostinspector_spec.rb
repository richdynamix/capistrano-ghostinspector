require 'spec_helper'

describe "Ghostinspector" do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend(Capistrano::Spec::ConfigurationExtension)

    Capistrano::Ghostinspector.load_into(@configuration)
  end

  subject { @configuration }

	context "when running capistrano:ghostinspector:run" do
		before do
			@configuration.set :gitest, 'home'
		end

	    it "it should define tests" do
			@configuration.fetch(:gitest).should == 'home'
		end

	end

end







