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

      def get(path, params = {})
        login unless @auth_id
        params[:page] ||= {}
        params[:page][:number] ||= 1
        params[:page][:size]   ||= 25
        unpack Typhoeus.get(url_for(path), headers: { 'Accept' => 'application/vnd.api+json' }, params: sign(params))
        Placewise::Api.repo[path.split('/').first.to_sym]
      end

      private

      def url_for(path, id = nil)
        "#{@base_url}/#{path}#{"/#{id}" if id}"
      end

      def sign(params)
        timestamp = Time.now.to_i
        params.merge({
          auth_id:        @auth_id,
          auth_token:     Digest::MD5.hexdigest("#{timestamp}:#{@auth_token}"),
          auth_timestamp: timestamp
        })
      end

      def model_for(type)
        type.capitalize!
        if Placewise::Api.const_defined?(type)
          Placewise::Api.const_get(type)
        else
          Placewise::Api.const_set(type, Struct.new(:id, :type, :attributes, :links, :relationships)) do
            def attributes
              attributes ||= {}
            end
          end
        end
      end

      def unpack(response)
        if response.success?
          json     = JSON.parse(response.response_body)
          data     = json['data']
          included = json['included'] || []
          if data.is_a?(Array)
            data.each { |d| Placewise::Api.repo[d['type'].to_sym] << model_for(d['type']).new(d) }
          else
            Placewise::Api.repo[data['type'].to_sym] << model_for(data['type']).new(
              data['id'], data['type'], data['attributes'], data['links'], data['relationships']
            )
          end
          included.each { |d| Placewise::Api.repo[d['type'].to_sym] << model_for(d['type']).new(d) }
        else
          fail "Something failed..."
        end
      end
    end
  end
end
