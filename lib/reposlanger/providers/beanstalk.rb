require 'reposlanger'
require 'reposlanger/providers/beanstalk/api'

module Reposlanger
  module Providers
    class Beanstalk
      include Reposlanger::Provider

      metadata_map  :title            => :title,
                    :default_branch   => :default_branch,
                    :vcs              => :vcs

      def self.api(options = {})
        API.new(options)
      end

      def pull(repo)
        if repo.metadata["vcs"] == "git"
          super
        else
          unless system "which svn2git > /dev/null 2>&1"
            raise "svn2git not found - try `gem install svn2git`"
          end

          # TODO: actually check output of the commands to see if this works
          # also break this all out somewhere
          repo.commander.register_dir(:svn, "svn")
          repo.commander.create_dir(:svn)
          svn_dir = repo.commander.path_for(:svn)
          svn_creds = "--source-username #{api.username} --source-password #{api.password}"
          local_uri = "file://#{svn_dir}"
          repo.cmd "svnadmin create #{svn_dir}", :svn
          repo.cmd "echo '#!/bin/sh\n\nexit 0' > #{svn_dir}/hooks/pre-revprop-change", :svn
          repo.cmd "chmod +x #{svn_dir}/hooks/pre-revprop-change", :svn
          repo.cmd "svnsync init #{local_uri} #{clone_url(repo)} #{svn_creds}", :svn
          repo.cmd "svnsync sync #{local_uri} #{svn_creds}", :svn

          svn_list = repo.cmd("svn list #{local_uri}", :svn).split("\n")

          git2svn_flags = if svn_list.include?("trunk/")
            flags = ["--trunk trunk"]
            flags << (svn_list.include?("branches") ? "--branches branches"
                                                   : "--nobranches")
            flags << (svn_list.include?("tags") ? "--tags tags" : "--notags")
            flags.join(" ")
          else
            "--nobranches --notags --rootistrunk"
          end

          repo.cmd "svn2git #{local_uri} #{git2svn_flags} -v"
        end
      end

      def create_remote(repo)
        repo.metadata["vcs"] = "git"
        super
      end

      def clone_url(repo)
        if repo.metadata["vcs"] == "git"
          "git@#{api.domain}.beanstalkapp.com:/#{repo.name}.git"
        else
          "https://#{api.domain}.svn.beanstalkapp.com/#{repo.name}/"
        end
      end

      def remote_exists?(repo)
        begin
          # could memoize this, but would need to be careful to expire
          api.get(repo.name)["name"] && true
        rescue NoMethodError
          false
        end
      end

    end
  end
end