require 'reposlanger'
require 'reposlanger/providers/github/api'

module Reposlanger
  module Providers
    class Github

      include Reposlanger::Provider

      def self.api(options = {})
        API.new(options)
      end

      def do_push(path = :git)
        api.create(name, metadata_to_attributes) unless remote_exists?
        super
      end

      def do_pull
        self.metadata = attributes_to_metadata
        super
      end

      # TODO: might have to break this into pull and push urls
      def clone_url
        api.get(name).ssh_url rescue nil
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

      def metadata_to_attributes
        return {} unless metadata

        METADATA_MAP.each_with_object({}) do |kv, h|
          if val = metadata[kv[1].to_s]
            h[kv[0].to_sym] = val
          end
        end
      end

      def attributes_to_metadata
        proj = api.get(name)

        METADATA_MAP.each_with_object({}) do |kv, h|
          h[kv[1].to_s] = proj[kv[0]]
        end
      end

      def remote_exists?
        begin
          api.get(name) && true
        rescue ::Github::Error::NotFound
          false
        end
      end
    end

  end
end