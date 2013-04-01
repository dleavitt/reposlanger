module Reposlanger
  module Providers
    class Beanstalk
      class API
        include HTTParty

        attr_accessor :domain, :username, :password, :repo

        format :json
        headers 'Content-Type'  => 'application/json',
                'User-Agent'    => 'Reposlanger'


        def initialize(options)
          @domain   = options[:domain]
          @username = options[:username]
          @password = options[:password]
        end

        def list
          do_request(:get, "/repositories.json").map { |r| r["repository"]["name"] }
        end

        def get(name)
          do_request(:get, "/repositories.json")
            .find { |r| r["repository"]["name"] ==  name}["repository"] \
            or raise "No repo '#{name}' found"
        end

        def create(name, body = {})
          body = { name: name, title: name, type_id: "git" }.merge(body)
          do_request :post, "/repositories.json", body: { repository: body }.to_json
        end

        def base_url
          "https://#{domain}.beanstalkapp.com/api"
        end

        def do_request(verb, url, options = {}, &block)
          options = { basic_auth: { username: username,
                                    password: password } }.merge(options)

          self.class.send verb, "#{base_url}#{url}", options, &block
        end
      end
    end
  end
end