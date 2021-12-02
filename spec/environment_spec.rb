# frozen_string_literal: true

require_relative '../lib/base/environment'

describe Environment do
  it 'should support some basic environment variables' do
    env = Environment.new({ 'DEBUG' => false })
    expect(File.exist?(env.get_env('HOME'))).to eq(true)
    expect(File.exist?(env.get_env('DEV_ROOT'))).to eq(true)
    expect(env.debug?).to eq(false)
    expect(File.exist?(env.home_dir)).to eq(true)
    expect(File.exist?(env.log_dir)).to eq(true)
    expect(File.exist?(env.make_dir)).to eq(true)
    expect(File.exist?(env.publish_dir)).to eq(true)
    expect(File.exist?(env.wrk_dir)).to eq(true)
    expect(env.machine.length).to be > 0
    expect(env.user.length).to be > 0
  end

  it 'should be able to modify it environment variables independently' do
    env1 = Environment.new
    env2 = Environment.new({ 'DEV_ROOT' => "#{File.dirname(__FILE__)}/dev_spec", 'DEBUG' => true })
    # expect(env2.debug?).to eq(true)
    expect(env1.get_env('DEV_ROOT')).not_to eq(env2.get_env('DEV_ROOT'))
  end

  it 'should NOT be an admin' do
    expect(Environment.default.admin?).to eq(false)
  end
end
