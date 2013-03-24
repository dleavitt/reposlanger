require 'reposlanger'

module Reposlanger
  module Providers
    class Bitbucket
      include Reposlanger::Provider

      def self.api(options = {})
        BitBucket.new(defaults.merge(options))
      end

      def do_push(path = :git)
        unless remote_exists?
          params = metadata_to_attributes
          params[:name] = name

          api.repos.create params
        end

        super
      end

      def do_pull
        self.metadata = attributes_to_metadata
        super
      end

      def clone_url
        "git@bitbucket.org:#{api.user}/#{name}.git"
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

      def metadata_to_attributes
        return {} unless metadata

        METADATA_MAP.each_with_object({}) do |kv, h|
          if val = metadata[kv[1].to_s]
            h[kv[0].to_sym] = val
          end
        end
      end

      def attributes_to_metadata
        repo_attributes = api.repos.get(api.user, name)

        METADATA_MAP.each_with_object({}) do |kv, h|
          h[kv[1].to_s] = repo_attributes[kv[0]]
        end
      end

      def remote_exists?
        begin
          # could memoize this, but would need to be careful to expire
          api.repos.get(api.user, name) && true
        rescue BitBucket::Error::NotFound
          puts "Bitbucket repo #{name} does not exist"
          false
        end
      end
    end
  end
end