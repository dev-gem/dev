require_relative '../lib/base/gemspec.rb'
require 'rake'

describe Gemspec do

  it "should be able to determine latest published version" do
    #expect(Gemspec.latest_published_version('dev').split('.')[]).to eq('2.0.268')
  end

end