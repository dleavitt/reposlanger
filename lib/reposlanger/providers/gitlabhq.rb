require 'reposlanger'

module Reposlanger
  module Providers
    class Gitlabhq
      include Reposlanger::Provider

      def self.api(options = {})
        Gitlab.client(options)
      end

      def do_push(path = :git)
        unless remote_exists?
          api.create_project(name, metadata_to_attributes)
        end

        super
      end

      def clone_url
        "git@#{URI.parse(api.endpoint).host}:#{name}.git"
      end

      # additional utility methods
      METADATA_MAP =         {
        :wiki_enabled     => :wiki,
        :issues_enabled   => :issues,
        :description      => :description,
        :private          => :private,
        :default_branch   => :default_branch,
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
        proj = api.project(name)

        METADATA_MAP.each_with_object({}) do |kv, h|
          h[kv[1].to_s] = proj.send([kv[0]])
        end
      end

      def remote_exists?
        begin
          api.project(name) && true
        rescue Gitlab::Error::NotFound
          false
        end
      end
    end

  end
end