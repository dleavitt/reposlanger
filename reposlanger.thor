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