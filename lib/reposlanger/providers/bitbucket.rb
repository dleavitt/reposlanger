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
          api.repos.create :name             => name,
                           :description      => "",
                           :is_private       => true,
                           :has_issues       => false,
                           :has_wiki         => false,
                           :no_public_forks  => true
        end
        super
      end

      def clone_url
        "git@bitbucket.org:#{api.user}/#{name}.git"
      end

      def remote_exists?
        begin
          api.repos.get(api.user, name) && true
        rescue BitBucket::Error::NotFound
          puts "Bitbucket repo #{name} exists"
          false
        end
      end

      def retrieve_metadata
        api.repos.get(api.user, name)
      end
    end

  end
end