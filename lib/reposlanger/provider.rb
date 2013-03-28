require 'reposlanger'
require 'json'

module Reposlanger
  module Provider
    def self.included(base)
      base.extend ClassMethods
      Reposlanger.providers[base.provider_name] = base
    end

    module ClassMethods
      def provider_name
        self.name.underscore.split("/")[-1]
      end

      def api(options = {})
        nil
      end
    end

    attr_accessor :name, :options

    def initialize(name, options = {})
      @name = name
      @options = options.symbolize_keys
      @options.delete :provider
    end

    def pull(repo)
      # TODO: to update an existing repo, need to checkout each branch and
      # pull individually
      before_pull(repo)
      repo.cmd "git clone -n -o #{name} #{clone_url(repo)} ."
      repo.commander.remote_branches(name).each do |branch|
        repo.cmd "git branch --track #{branch} #{name}/#{branch}"
      end
      after_pull(repo)
    end

    # Usually this will be the path of a repo from a different provider
    def push(repo)
      before_push(repo)

      repo.cmd "git remote add #{name} #{clone_url(repo)}"
      repo.cmd "git push --all #{name}"
      after_push(repo)
    end

    def before_pull(repo); end
    def after_pull(repo); end

    def before_push(repo); end
    def after_push(repo); end

    def retrieve_metadata(repo); end
    def create_remote(repo); end

    def repos
      raise "not implemented"
    end

    def provider_name
      self.class.provider_name
    end

    def api
      @api ||= self.class.api(options)
    end

    # Methods to override

    # TODO: make this a lambda
    def clone_url
      raise "not implemented"
    end
  end
end