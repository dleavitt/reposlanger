module Reposlanger
  module Providers
    class Gitlabhq
      class API
        include HTTParty

        attr_accessor :endpoint, :private_token, :host

        format :json
        headers 'Accept' => 'application/json'

        def initialize(options)
          @endpoint       = options[:endpoint]
          @host           = URI.parse(@endpoint).host
          @private_token  = options[:private_token]
        end

        def list
          do_request(:get, '/projects', query: { per_page: 500 }).map do |r|
            r["name"]
          end
        end

        def get(name)
          do_request(:get, "/projects/#{name}")
        end

        def create(name, body = {})
          body = { name: name }.merge(body)
          do_request :post, "/projects", body: body
        end

        def do_request(verb, url, options = {}, &block)
          options[:query] ||= {}
          options[:query][:private_token] = private_token

          self.class.send verb, endpoint + url, options, &block
        end
      end
    end
  end
end