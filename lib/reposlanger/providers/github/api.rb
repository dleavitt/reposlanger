module Reposlanger
  module Providers
    class Github
      class API
        attr_accessor :org, :user, :api

        def initialize(options)
          @org = options[:org]
          @user = options[:login]
          @api = ::Github::Repos.new(options)
        end

        def list
          options = { per_page: 500 }
          options[:org] = org if org
          api.list(options).map(&:name)
        end

        def get(name)
          @repo ||= api.get(org || user, name)
        end

        def get!(name)
          @repo = nil
          get(name)
        end

        def create(name, options = {})
          options[:name] = name
          options[:org] = org
          api.create(options)
        end
      end
    end
  end
end