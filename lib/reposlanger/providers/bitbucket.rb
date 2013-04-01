require 'reposlanger'
require 'reposlanger/providers/bitbucket/api'

module Reposlanger
  module Providers
    class Bitbucket
      include Reposlanger::Provider

      metadata_map  :has_wiki         => :wiki,
                    :has_issues       => :issues,
                    :logo             => :logo,
                    :website          => :website,
                    :description      => :description,
                    :is_private       => :private,
                    :no_public_forks  => :private,
                    :language         => :language

      def self.api(options = {})
        API.new(options)
      end

      def clone_url(repo)
        "git@bitbucket.org:#{api.username}/#{repo.name}.git"
      end

      # additional utility methods
      
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