class Project
  attr_accessor :name, :gitlab, :bitbucket, :repo, :commander

  def initialize(name, options)
    @name = name
    @gitlab = options[:gitlab_api]
    @bitbucket = options[:bitbucket_api]
    @root = options[:root]
    @commander = Commander.new(git_repo_path)
  end

  def migrate
    puts "\n\n"
    puts "--> Running migrate for #{name}"
    clone
    create_bitbucket_repo unless exists_on_bitbucket?
    push
  end

  def exists_on_bitbucket?
    begin
      bitbucket_repo && true
    rescue BitBucket::Error::NotFound
      puts "Bitbucket repo #{name} exists"
      false
    end
  end

  def clone
    puts "--> Cloning repo #{name}"
    FileUtils.mkdir_p(git_repo_path)
    cmd "git clone -o gitlab #{gitlab_clone_url} ."
    @commander.remote_branches("gitlab").each do |remote, local|
      cmd "git branch --track #{local} #{remote}"
    end
  end

  def push
    puts "--> Pushing repo #{name} to bitbucket"
    cmd "git remote add bitbucket #{bitbucket_clone_url}"
    cmd "git push --all bitbucket"
  end

  def create_bitbucket_repo
    puts "--> Creating repo #{name} on bitbucket"
    @bitbucket.repos.create :name             => name,
                            :description      => gitlab_project.description,
                            :is_private       => true,
                            :has_issues       => false,
                            :has_wiki         => false,
                            :no_public_forks  => true
  end

  def delete
    cmd "rm -rf ../#{name}"
  end

  def cmd(command)
    @commander.run command
  end

  def gitlab_project
    @gitlab_project ||= @gitlab.project(name)
  end

  def bitbucket_repo
    @bitbucket_repo ||= bitbucket.repos.get(bitbucket.user, name)
  end

  private

  def gitlab_clone_url
    "git@#{URI.parse(@gitlab.endpoint).host}:#{name}.git"
  end

  def bitbucket_clone_url
    "git@bitbucket.org:#{bitbucket.user}/#{name}.git"
  end

  def git_repo_path
    File.join(@root, "git", name)
  end
end