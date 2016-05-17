require 'spec_helper'

describe Placewise::Api do
  it 'has a version number' do
    expect(Placewise::Api::VERSION).not_to be nil
  end

  it 'can be configured' do
    Placewise::Api.configure do |config|
      config.email    = 'test@email.com'
      config.password = 'asdfasdfasdf'
    end

    expect(Placewise::Api.client).to_not be nil
  end
end
