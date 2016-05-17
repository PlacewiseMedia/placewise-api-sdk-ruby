module Placewise
  module Api
    class Client
      def initialize(email, password, base_url)
        @email, @password = email, password
        @base_url = base_url
      end

      def login
        # TODO!!
        @auth_id, @auth_token = 'foo', 'bar'
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
