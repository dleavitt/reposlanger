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

        def list(opts = {})
          options = { :per_page => 500 }.merge(opts)
          # if no org specified for api
          # or if org specified in options but explicitly set to nil
          # TODO: make less confusing
          unless ! org || (opts.has_key?(:org) && ! opts[:org])
            options[:org] = @org
          end
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