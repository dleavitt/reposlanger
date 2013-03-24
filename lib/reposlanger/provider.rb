require 'reposlanger'

module Reposlanger
  module Provider
    def self.included(base)
      base.extend ClassMethods
      Reposlanger.providers[base.provider_name] = base
    end

    module ClassMethods
      # TODO: add a nice idiomatic way of setting options
      def configure(options = {})
        @defaults ||= {}
        @defaults.merge!(options)
      end

      def defaults
        @defaults || {}
      end

      def provider_name
        self.name.underscore.split("/")[-1]
      end

      # Override this with custom logic to
      def repos
        raise "not implemented"
      end
    end

    # TODO: some notion of mutually intelligable per-repo options
    #   - description
    #   - privacy

    attr_accessor :name, :options, :cli

    def initialize(name, options = {})
      @name = name
      @cli = Reposlanger::CLI.new(name, provider_name)
      @options = self.class.defaults.merge(options)
    end

    def pull
      log "--> Cloning repo #{name}"
      @cli.create
      do_pull
    end

    # Usually this will be the path of a repo from a different provider
    def push(path = :git)
      do_push(path)
    end

    # Removes the local repo
    # TODO: only run from cli, make interactive
    def clear
      # terrifying
      @cli.destroy
    end

    def log(message)
      puts message
    end

    def cmd(command, dir = :git)
      @cli.run(command, dir)
    end

    def provider_name
      self.class.provider_name
    end

    # Methods to override

    # TODO: make this a lambda
    def clone_url
      raise "not implemented"
    end

    protected

    def do_pull
      cmd "git clone -o #{provider_name} #{clone_url} ."
      @cli.remote_branches.each do |branch|
        cmd "git branch --track #{branch} #{provider_name}/#{branch}"
      end
    end

    def do_push(path = :git)
      cmd "git remote add #{provider_name} #{clone_url}"
      cmd "git push --all #{provider_name}"
    end

  end
end