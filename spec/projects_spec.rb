require_relative '../lib/base/projects.rb'

describe Projects do
	it "should be able to import projects" do
		PROJECTS.import
	end
end