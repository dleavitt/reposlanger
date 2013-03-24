require 'reposlanger'
require 'json'

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

      def api(options = {})
        nil
      end

      # Override this with custom logic to get a list of all repos
      def repos
        raise "not implemented"
      end
    end

    # TODO: some notion of mutually intelligable per-repo options
    #   - description
    #   - privacy

    attr_accessor :name, :options, :cli, :metadata

    def initialize(name_or_repo, options = {})
      # allow either a string or another repo to be passed
      @name = name_or_repo.respond_to?(:name) ? name_or_repo.name : name_or_repo
      @cli = Reposlanger::Commander.new(name, provider_name)
      @options = self.class.defaults.merge(options)
    end

    def pull
      log "--> Cloning repo #{name}"
      @cli.create
      do_pull
      write_metadata
    end

    # Usually this will be the path of a repo from a different provider
    def push
      read_metadata
      do_push
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

    def api
      @api ||= self.class.api(options)
    end

    # use git notes storage for metadata
    # probably not optimal, but hey, it's right there

    def read_metadata
      self.metadata = begin
        JSON.parse(cmd "git notes show")
      rescue JSON::ParserError
        nil
      end
    end

    def write_metadata
      cmd "git notes add -f -m '#{JSON.dump(metadata)}'" if metadata
    end

    def update_metadata(hsh)

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

    def do_push
      cmd "git remote add #{provider_name} #{clone_url}"
      cmd "git push --all #{provider_name}"
    end
  end
end