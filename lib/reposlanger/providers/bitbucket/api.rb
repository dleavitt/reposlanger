module Reposlanger
  module Providers
    class Bitbucket
      class API
        include HTTParty

        attr_accessor :org, :username, :password, :repo

        base_uri "https://api.bitbucket.org/1.0"
        format :json

        DEFAULT_PARAMS = {
          "website"         => "",
          "is_private"      => true,
          "has_issues"      => false,
          "has_wiki"        => false,
          "scm"             => "git",
          "no_public_forks" => true,
        }

        def initialize(options)
          @username = options[:username]
          @password = options[:password]
        end

        def list
          do_request(:get, "/user/repositories").map { |r| r["name"].downcase }
        end

        def get(name)
          do_request(:get, "/repositories/#{username}/#{name.downcase}")
        end

        def create(name, body = {})
          body = DEFAULT_PARAMS.merge(name: name).merge(body)
          do_request :post, "/repositories/", body: body
        end

        def do_request(verb, url, options = {}, &block)
          options = {
            basic_auth: { username: username, password: password }
          }.merge(options)

          self.class.send verb, url, options, &block
        end
      end
    end
  end
end