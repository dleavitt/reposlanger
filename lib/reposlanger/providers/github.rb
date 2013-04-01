require 'reposlanger'
require 'reposlanger/providers/github/api'

module Reposlanger
  module Providers
    class Github
      include Reposlanger::Provider

      metadata_map  :has_wiki     => :wiki,
                    :has_issues   => :issues,
                    :description  => :description,
                    :private      => :private,
                    :website      => :homepage

      def self.api(options = {})
        API.new(options)
      end

      # TODO: might have to break this into pull and push urls
      def clone_url(repo)
        api.get(repo.name)['ssh_url']
      end

      def remote_exists?(repo)
        api.get(repo.name)["name"] && true
      end
    end
  end
end