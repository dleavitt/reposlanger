require 'reposlanger'

module Reposlanger
  module Providers
    class Bitbucket
      include Reposlanger::Provider

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

      def api
        @api ||= BitBucket.new(options)
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
    end

  end
end