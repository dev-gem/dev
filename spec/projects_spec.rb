# frozen_string_literal: true

require_relative '../lib/base/projects'

describe Projects do
  it 'should be have a valid env reference' do
    projects = Projects.new
    expect(projects.env).not_to eq(nil)
  end
end
