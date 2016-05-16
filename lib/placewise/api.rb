require "placewise/api/version"

module Placewise
  module Api
    class << self
      attr_accessor :configuration
    end

    class Configuration
      attr_accessor :api_key, :email, :password, :base_url

      def initialize
        @api_key  = ENV['']
        @email    = ENV['']
        @password = ENV['']
        @base_url = 'https://api.placewise.com'
      end
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield configuration
    end
  end
end
