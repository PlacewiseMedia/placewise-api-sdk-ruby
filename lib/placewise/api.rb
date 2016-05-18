require "placewise/api/version"
require "placewise/api/client"

module Placewise
  module Api
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
      @configuration ||= Configuration.new
      yield configuration
    end

    class << self
      attr_accessor :configuration

      def client
        @client ||= Client.new(
          configuration.email,
          configuration.password,
          configuration.base_url
        )
      end

      def repo
        @repo ||= Hash.new { |h, k| h[k] = [] }
      end
    end
  end
end
