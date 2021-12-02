# frozen_string_literal: true

require_relative '../lib/base/dir'

describe Dir do
  it 'should be able to get_latest_mtime' do
    expect(Dir.get_latest_mtime(File.dirname(__FILE__))).not_to eq(nil)
  end
end
