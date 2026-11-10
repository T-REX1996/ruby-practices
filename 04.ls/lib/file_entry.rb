# frozen_string_literal: true

require 'etc'
require 'forwardable'

class FileEntry
  extend Forwardable

  attr_reader :name

  def_delegators :@stat, :mode, :setuid?, :setgid?, :sticky?, :nlink, :size, :mtime, :blocks, :symlink?
  def_delegator :@stat, :ftype, :file_type

  def initialize(directory, name)
    @directory = directory
    @name = name
    @stat = File.lstat(File.join(directory, name))
  end

  def owner
    Etc.getpwuid(@stat.uid).name
  end

  def group
    Etc.getgrgid(@stat.gid).name
  end

  def link_target
    File.readlink(File.join(@directory, @name)) if symlink?
  end
end
