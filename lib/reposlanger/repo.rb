module Reposlanger
  class Repo
    attr_accessor :name, :source, :target, :commander, :metadata

    def initialize(name, options = {})
      @name = name
      @source = options[:source]
      @target = options[:target]
      @commander = Reposlanger::Commander.new(name)
    end

    def copy
      pull
      push
    end

    # TODO: raise error if source not defined
    def pull
      self.metadata = @source.retrieve_metadata(self)
      @commander.create_dir
      @source.before_pull(self)
      @source.pull(self)
      @source.after_pull(self)
      @commander.write_metadata(metadata)
    end

    def push
      self.metadata = @commander.read_metadata
      @target.create_remote(self)
      @target.before_push(self)
      @target.push(self)
      @target.after_push(self)
    end

    # Removes the local repo
    # TODO: clear scratch dir as well
    def rm
      path = @commander.path_for(:git)
      cmd "rm -rf #{path}" if block_given? ? yield(path) : true
    end

    def cmd(command)
      commander.run(command)
    end
  end
end