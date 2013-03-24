# Run commands in a directory
class Commander
  attr_accessor :path

  def initialize(path)
    @path = path
  end

  def run(cmd)
    puts cmd
    `cd #{path} && #{cmd}`
  end

  # returns a list of branch names for the remote
  def remote_branches(remote)
    run("git branch -r").split("\n")
      .map    { |r| r.chomp.gsub(/^\s+/, "") }
      .select { |r| r[remote] && ! r["HEAD"] && ! r["master"] }
      .map    { |r| r.gsub("#{remote}/", "") }
  end
end