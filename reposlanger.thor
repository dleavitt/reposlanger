require "rubygems"
require "bundler"
require "yaml"
require "thread"
Bundler.require

LIBS = Dir["./lib/**/*.rb"]

LIBS.each(&method(:require))

class RS < Thor

  REPO_DIR = Dir[File.join(File.dirname(__FILE__), "repos")]

  desc "migrate REPO", "do full migration on a repo"
  def migrate(name)
    repo(name).migrate
  end

  desc "projects", "list all (up to 500) gitlab projects"
  def projects
    gitlab_api.projects(per_page: 500).each { |p| puts p.name }
  end

  desc "batch", "migrate all known gitlab projects to bitbucket"
  method_options %w( concurrency -c ) => 1
  def batch
    c = options[:concurrency]
    project_names = gitlab_api.projects(per_page: 500).map(&:name)

    queue = Queue.new
    project_names.each { |name| queue << name }
    threads = c.times.map do
      Thread.new do
        until queue.empty?
          name = queue.pop(true) rescue nil
          repo(name).migrate
        end
      end
    end

    threads.each(&:join)
  end

  desc "console", "run a console in this context"
  def console
    binding.pry
  end

  no_tasks do
    def repo(name)
      Project.new name, :gitlab_api     => gitlab_api,
                        :bitbucket_api  => bitbucket_api,
                        :root           => REPO_DIR
    end

    def settings
      @settings ||= YAML.load_file('config.yml')
    end

    def gitlab_api
      @gitlab_api ||= Gitlab.client(settings["gitlab"])
    end

    def bitbucket_api
      @bitbucket_api ||= BitBucket.new(settings["bitbucket"])
    end

    def reload!
      LIBS.each(&method(:load))
    end
  end
end