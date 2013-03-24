require 'reposlanger'

module Reposlanger
  module Providers
    class Gitlabhq
      include Reposlanger::Provider

      def self.api(options = {})
        Gitlab.client(options)
      end

      def do_push(path = :git)
        
      end

      def clone_url
        "git@#{URI.parse(api.endpoint).host}:#{name}.git"
      end
    end

  end
end