module Reposlanger
  module Providers
    class Github
      class API
        include HTTParty

        attr_accessor :org, :username, :password, :repo

        base_uri "https://api.github.com"
        format :json

        def initialize(options)
          @org      = options[:org]
          @username = options[:username]
          @password = options[:password]
        end

        def list
          # TODO: page through results
          endpoint = org ? "/orgs/#{org}/repos" : "/users/#{username}/repos"
          query = { per_page: 100, type: "all" }
          do_request(:get, endpoint, query: query).map { |r| r["name"] }
        end

        def get(name)
          do_request(:get, "/repos/#{org || username}/#{name}")
        end

        def create(name, body = {})
          endpoint  = org ? "/orgs/#{org}/repos" : "/user/repos"
          body      = { private: true, name: name }.merge(body)

          do_request :post, endpoint, body: body.to_json
        end

        def do_request(verb, url, options = {}, &block)
          options = {
            basic_auth: { username: username, password: password },
            headers: { "User-Agent" => "Reposlanger" },
          }.merge(options)

          self.class.send verb, url, options, &block
        end
      end
    end
  end
end