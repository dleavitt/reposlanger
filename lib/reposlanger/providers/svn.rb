require 'reposlanger'

module Reposlanger
  module Providers
    class SVN
      include Reposlanger::Provider

      def repos
        @options[:repos]
      end

      def retrieve_metadata(repo)
        {}
      end

      # additional utility methods

      def pull(repo)
        unless system "which svn2git > /dev/null 2>&1"
          raise "svn2git not found - try `gem install svn2git`"
        end

        local_uri = "#{@options[:base]}#{repo.name}"

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

      def remote_exists?(repo)
        false
      end

      def push(repo)
        raise "Not implemented for vanilla git repos"
      end

      def before_push(repo)
        raise "Not implemented for vanilla git repos"
      end

      def after_push(repo)
        raise "Not implemented for vanilla git repos"
      end
    end
  end
end