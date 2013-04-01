require 'reposlanger'
require 'reposlanger/providers/beanstalk/api'

module Reposlanger
  module Providers
    class Beanstalk
      include Reposlanger::Provider

      metadata_map  :title        => :title,
                    :default_map  => :default_map

      def self.api(options = {})
        API.new(options)
      end


      def clone_url(repo)
        "git@#{api.domain}.beanstalkapp.com:/#{repo.name}.git"
      end

      def remote_exists?(repo)
        begin
          # could memoize this, but would need to be careful to expire
          api.get(repo.name)["name"] && true
        rescue NoMethodError
          false
        end
      end

    end
  end
end