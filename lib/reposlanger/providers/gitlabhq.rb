require 'reposlanger'

module Reposlanger
  module Providers
    class Gitlabhq
      include Reposlanger::Provider

      def do_push(path = :git)
        raise "not implemented"
      end

      def api
        p options
        @api ||= Gitlab.client(options)
      end

      def clone_url
        "git@#{URI.parse(api.endpoint).host}:#{name}.git"
      end
    end

  end
end