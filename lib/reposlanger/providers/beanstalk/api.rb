module Reposlanger
  module Providers
    class Beanstalk
      class API
        include HTTParty

        format :json

        attr_accessor :domain, :username, :password, :repo
        # debug_output $stdout

        def initialize(options)
          @domain   = options[:domain]
          @username = options[:username]
          @password = options[:password]
        end

        def list
          do_request(:get, "/repositories.json").map { |r| r["repository"]["name"] }
        end

        def get(name)
          @repo ||= do_request(:get, "/repositories.json")
            .find { |r| r["repository"]["name"] ==  name}["repository"] or raise "No repo '#{name}' found"
        end

        def get!(name)
          @repo = nil
          get(name)
        end

        def create(name, options = {})
          options = { name: name, title: name, type_id: "git" }.merge(options)
          do_request :post, "/repositories.json", options
        end

        def base_url
          "https://#{domain}.beanstalkapp.com/api"
        end

        def do_request(verb, url, options = {}, &block)
          options = {
            basic_auth: { username: username, password: password }
          }.merge(options)

          self.class.send verb, "#{base_url}#{url}", options, &block
        end
      end
    end
  end
end