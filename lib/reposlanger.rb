module Reposlanger

  require File.join(File.dirname(__FILE__), "reposlanger", "provider")
  require File.join(File.dirname(__FILE__), "reposlanger", "cli")

  def self.providers
    @@providers ||= {}
  end

  # TODO: make me editable some day
  # maybe you should define a working folder
  # maybe it should be system-level
  def self.data_path
    File.expand_path File.join File.dirname(__FILE__), "..", "data"
  end

  def self.new_repo(provider_name, repo_name, options = {})
    @@providers[provider_name.to_s].new(repo_name, options)
  end

  def self.configure(provider_name, options)
    @@providers[provider_name.to_s].configure(options)
  end
end

unless String.new.respond_to? :underscore
  class String
    def underscore
      word = self.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end
  end
end

