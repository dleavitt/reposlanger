require "rubygems"
require "bundler"
require "yaml"
require "thread"
Bundler.require

# hackey, remove
LIBS = Dir["./lib/**/*.rb"]

# LIBS.each(&method(:require))
require "./lib/reposlanger"

class RS < Thor

  # desc "batch", "migrate all known gitlab projects to bitbucket"
  # method_options %w( concurrency -c ) => 1
  # def batch
  #   c = options[:concurrency]
  #   project_names = gitlab_api.projects(per_page: 500).map(&:name)

  #   queue = Queue.new
  #   project_names.each { |name| queue << name }
  #   threads = c.times.map do
  #     Thread.new do
  #       until queue.empty?
  #         name = queue.pop(true) rescue nil
  #         repo(name).migrate
  #       end
  #     end
  #   end

  #   threads.each(&:join)
  # end

  desc "copy SOURCE TARGET REPO_NAME", "copy a repo from one provider to another"
  def copy(source_provider, target_provider, repo_name)
    env

    source = Reposlanger.new_repo(source_provider, repo_name)
    target = Reposlanger.new_repo(target_provider, repo_name)

    source.pull
    target.push
  end

  desc "copy_batch SOURCE TARGET", "copy all repos from one provider to another"
  method_option :concurrency, default: 1, aliases: "-c", type: :numeric
  method_option :include, default: nil, aliases: "-i", type: :array
  method_option :exclude, default: nil, aliases: "-e", type: :array
  def copy_batch(source_provider, target_provider)
    env
    repos = Reposlanger.providers[source_provider].repos
    repos &= options[:include] if options[:include]
    repos -= options[:exclude] if options[:exclude]

    c = options[:concurrency]
    queue = Queue.new

    repos.each { |repo_name| queue << repo_name }
    threads = c.times.map do
      Thread.new do
        until queue.empty?
          repo_name = queue.pop(true) rescue nil
          if repo_name
            source = Reposlanger.new_repo(source_provider, repo_name)
            target = Reposlanger.new_repo(target_provider, repo_name)
            source.pull
            target.push
          end
        end
      end
    end

    threads.each(&:join)
  end

  desc "list SERVICE", "list all repos for a service"
  def list(provider)
    env
    Reposlanger.providers[provider].repos.each { |r| puts r }
  end

  desc "console", "run a console in this context"
  def console
    env
    binding.pry
  end

  no_tasks do
    def env
      require "./lib/reposlanger/providers/gitlabhq"
      require "./lib/reposlanger/providers/bitbucket"
      require "./lib/reposlanger/providers/github"
      Reposlanger.configure("gitlabhq", settings["gitlabhq"])
      Reposlanger.configure("bitbucket", settings["bitbucket"])
      Reposlanger.configure("github", settings["github"])
    end

    def settings
      @settings ||= YAML.load_file('config.yml')
    end

    def reload!
      LIBS.each(&method(:load))
      env
    end
  end
end