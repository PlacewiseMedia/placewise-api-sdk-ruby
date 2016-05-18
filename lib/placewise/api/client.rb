require 'typhoeus'
require 'json'

module Placewise
  module Api
    class Client
      def initialize(email, password, base_url)
        @email, @password = email, password
        @base_url = base_url
      end

      def login
        response = Typhoeus.post(
          "#{@base_url}/accounts/login",
          body: { data: { attributes: { email: @email, password: @password } }, type: 'accounts' },
          headers: { 'Accept' => 'application/vnd.api+json' }
        )

        fail "Failed login" unless response.success?
        data = JSON.parse(response.response_body)['data']

        @auth_id    = data['id']
        @auth_token = data['attributes']['authentication_token']
      end

      def get(resource, id = nil)
        login unless @auth_id
        url_for(resource)
      end

      private

      def url_for(path, id = nil)
        sign "#{@base_url}/#{path}#{"/#{id}" if id}"
      end

      def sign(url)
        timestamp = Time.now.to_i
        token = Digest::MD5.hexdigest("#{timestamp}:#{@auth_token}")
        "#{url}?auth_id=#{@auth_id}&auth_token=#{token}&timestamp=#{timestamp}"
      end
    end
  end
end
