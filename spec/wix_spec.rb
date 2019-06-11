require_relative '../lib/apps/wix.rb'

describe Wix do
    it "should be able to set file names" do
        wxs_file="#{File.dirname(__FILE__)}/example.wxs_"
        expect(File.exists?(wxs_file)).to eq(true)

        example = IO.read(wxs_file)
        wxs = Wix.get_wix_with_files(example,"ApplicationFiles", ["bin/a.dll","bin/b.dll"])
        expect(wxs.include?('bin/a.dll')).to eq(true)
    end
end