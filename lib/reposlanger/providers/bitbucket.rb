require 'reposlanger'
require 'reposlanger/providers/bitbucket/api'

module Reposlanger
  module Providers
    class Bitbucket
      include Reposlanger::Provider

      def self.api(options = {})
        API.new(options)
      end

      def repos(options = {})
        api.list
      end

      def clone_url(repo)
        "git@bitbucket.org:#{api.username}/#{repo.name}.git"
      end

      # additional utility methods

      # map of bitbucket repo attributes to reposlanger metadata
      METADATA_MAP = {
        :has_wiki         => :wiki,
        :has_issues       => :issues,
        :logo             => :logo,
        :website          => :website,
        :description      => :description,
        :is_private       => :private,
        :no_public_forks  => :private,
        :language         => :language,
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

        api.create(repo.name, params) unless remote_exists?(repo)
      end

      def retrieve_metadata(repo)
        proj = api.get(repo.name)

        METADATA_MAP.each_with_object({}) do |(key, value), h|
          h[value.to_s] = proj[key]
        end
      end

      def remote_exists?(repo)
        begin
          # could memoize this, but would need to be careful to expire
          api.get(repo.name)["name"] && true
        rescue MultiJson::LoadError
          false
        end
      end
    end
  end
end