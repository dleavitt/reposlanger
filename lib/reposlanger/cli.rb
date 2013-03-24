module Reposlanger
  class CLI
    attr_reader :dirs, :repo_name, :provider_name
    # TODO: logging

    def initialize(repo_name, provider_name)
      @repo_name      = repo_name
      @provider_name  = provider_name

      base_path = Reposlanger.data_path
      provider_path = File.join(Reposlanger.data_path, provider_name)

      @dirs = {
        :base       => base_path,
        :provider   => provider_path,
        :git        => File.join(provider_path, "git", repo_name),
        :scratch    => File.join(provider_path, "scratch", repo_name)
      }
    end

    # Adds a new directory
    # name should be a symbol, value a subdir within "scratch"
    def register_dir(key, path)
      @dirs[key] = File.join @dirs[:scratch], path
    end

    # TODO: both "puts" line and backticks should respect logging settings
    def run(command, key = :git)
      puts command
      `cd #{path_for(key)} && #{command}`
    end

    def create(key = :git)
      FileUtils.mkdir_p(path_for(key))
    end

    def destroy
      run "rm -rf #{dirs[:git]}/../#{@repo_name}"
      run "rm -rf #{dirs[:scratch]}/../#{@repo_name}"
    end

    def path_for(key)
      key.is_a?(Symbol) ? dirs[key] : key
    end

    # returns a list of branch names for the remote
    # will this handle edge cases?
    def remote_branches
      run("git branch -r").split("\n")
        .map    { |r| r.chomp.gsub(/^\s+/, "") }
        .select { |r| r[provider_name] && ! r["HEAD"] && ! r["master"] }
        .map    { |r| r.gsub("#{provider_name}/", "") }
    end
  end
end