require 'reposlanger'
require 'reposlanger/providers/gitlabhq/api'

module Reposlanger
  module Providers
    class Gitlabhq
      include Reposlanger::Provider

      metadata_map  :wiki_enabled     => :wiki,
                    :issues_enabled   => :issues,
                    :description      => :description,
                    :private          => :private,
                    :default_branch   => :default_branch

      def self.api(options = {})
        API.new(options)
      end

      def clone_url(repo)
        "git@#{api.host}:#{repo.name}.git"
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