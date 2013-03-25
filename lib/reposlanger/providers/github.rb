require 'reposlanger'
require 'reposlanger/providers/github/api'

module Reposlanger
  module Providers
    class Github
      include Reposlanger::Provider

      def self.api(options = {})
        API.new(options)
      end

      def repos(options = {})
        api.list(options)
      end

      # TODO: might have to break this into pull and push urls
      def clone_url(repo)
        api.get(repo.name).ssh_url
      end

      # additional utility methods

      # map of github repo attributes to reposlanger metadata
      METADATA_MAP = {
        :has_wiki     => :wiki,
        :has_issues   => :issues,
        :description  => :description,
        :private      => :private,
        :website     => :homepage,
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
          api.get(repo.name) && true
        rescue ::Github::Error::NotFound
          false
        end
      end
    end

  end
end