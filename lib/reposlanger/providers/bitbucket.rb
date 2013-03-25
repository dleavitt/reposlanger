require 'reposlanger'

module Reposlanger
  module Providers
    class Bitbucket
      include Reposlanger::Provider

      def self.api(options = {})
        BitBucket.new(options)
      end

      def repos(options = {})
        api.repos.all.map(&:name)
      end

      def clone_url(repo)
        "git@bitbucket.org:#{api.user}/#{repo.name}.git"
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

        params[:name] = repo.name
        api.repos.create(params) unless remote_exists?(repo)
      end

      def retrieve_metadata(repo)
        proj = api.repos.get(api.user, repo.name.downcase)

        METADATA_MAP.each_with_object({}) do |(key, value), h|
          h[value.to_s] = proj[key]
        end
      end

      def remote_exists?(repo)
        begin
          # could memoize this, but would need to be careful to expire
          api.repos.get(api.user, repo.name.downcase) && true
        rescue BitBucket::Error::NotFound
          puts "Bitbucket repo #{name} does not exist"
          false
        end
      end
    end
  end
end