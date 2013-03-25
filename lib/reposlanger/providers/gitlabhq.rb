require 'reposlanger'

module Reposlanger
  module Providers
    class Gitlabhq
      include Reposlanger::Provider

      def self.api(options = {})
        Gitlab.client(options)
      end

      def repos(options = {})
        api.projects(options.merge({per_page: 500})).map(&:name)
      end

      def clone_url(repo)
        "git@#{URI.parse(api.endpoint).host}:#{repo.name}.git"
      end

      # additional utility methods
      METADATA_MAP = {
        :wiki_enabled     => :wiki,
        :issues_enabled   => :issues,
        :description      => :description,
        :private          => :private,
        :default_branch   => :default_branch,
      }

      def create_remote(repo)
        params = if repo.metadata
          METADATA_MAP.each_with_object({}) do |(key, value), h|
            if val = repo.metadata[value.to_s]
              h[key.to_sym] = val
            end
          end
        else
          {}
        end

        api.create_project(repo.name, params) unless remote_exists?(repo)
      end

      def retrieve_metadata(repo)
        proj = api.project(repo.name)

        METADATA_MAP.each_with_object({}) do |(key, value), h|
          h[value.to_s] = proj.send(key)
        end
      end

      def remote_exists?(repo)
        begin
          api.project(repo.name) && true
        rescue Gitlab::Error::NotFound
          false
        end
      end
    end

  end
end