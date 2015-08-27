require_relative '../lib/base/projects.rb'

describe Projects do
	it "should be have a valid dev reference" do
		projects=Projects.new
		expect(projects.dev).not_to eq(nil)
	end
end