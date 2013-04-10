require "rubygems"
require "bundler"
require "thread"
Bundler.require

# hackey, remove
$:.unshift File.expand_path("../lib", __FILE__)
# LIBS.each(&method(:require))
require "reposlanger"

class RS < Thor

  desc "mirror SOURCE TARGET REPO_NAME", "copy a repo from one remote to another"
  def mirror(source_remote_name, target_remote_name, repo_name)
    env
    repo = Reposlanger::Repo.new repo_name,
                                 :source => new_provider(source_remote_name),
                                 :target => new_provider(target_remote_name)

    repo.mirror
  end

  desc "clone SOURCE REPO_NAME", "clones a repo locally"
  def clone(source_remote_name, repo_name)
    env
    repo = Reposlanger::Repo.new repo_name,
                              :source => new_provider(source_remote_name)
    repo.pull
  end

  # TODO: update to new style
  desc "mirror_batch SOURCE TARGET", "copy all repos from one provider to another"
  method_option :concurrency, default: 1,   aliases: "-c", type: :numeric
  method_option :include,     default: nil, aliases: "-i", type: :array
  method_option :exclude,     default: nil, aliases: "-e", type: :array
  def mirror_batch(source_remote_name, target_remote_name)
    env

    repo_names = new_provider(source_remote_name).repos
    repo_names &= options[:include] if options[:include]
    repo_names -= options[:exclude] if options[:exclude]

    c = options[:concurrency]
    queue = Queue.new

    repo_names.each { |repo_name| queue << repo_name }
    threads = c.times.map do
      Thread.new do
        until queue.empty?
          if repo_name = queue.pop(true) rescue nil
            repo = Reposlanger::Repo.new(repo_name, {
              :source => new_provider(source_remote_name),
              :target => new_provider(target_remote_name),
            })

            repo.mirror
          end
        end
      end
    end

    threads.each(&:join)
  end

  desc "remotes", "list all remotes"
  def remotes
    settings.keys.each(&method(:puts))
  end

  desc "repos PROVIDER", "list all repos for a provider"
  def repos(provider)
    env
    new_provider(provider).repos.each { |r| puts r }
  end

  desc "rm REPO", "delete a local repo"
  def rm(repo_name)
    env
    repo = Reposlanger::Repo.new(repo_name)
    repo.rm { |path| yes?("Really delete #{repo_name} at '#{path}'?") }
  end

  desc "console", "run a console in this context"
  def console
    env
    binding.pry
  end

  no_tasks do
    def env
      require "reposlanger/repo"
      require "reposlanger/providers/gitlabhq"
      require "reposlanger/providers/bitbucket"
      require "reposlanger/providers/github"
      require "reposlanger/providers/beanstalk"
    end

    def new_provider(remote_name)
      raise "Remote #{remote_name} does not exist" unless settings[remote_name]
      Reposlanger.new_provider(remote_name, settings[remote_name])

    end

    def settings
      @settings ||= TOML.load_file('config.toml')
    end

    def reload!
      Dir["./lib/**/*.rb"].each(&method(:load))
      env
    end
  end
end