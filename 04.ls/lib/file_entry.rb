# frozen_string_literal: true

require 'etc'

class FileEntry
  attr_reader :name

  def initialize(directory, name)
    @directory = directory
    @name = name
    @stat = File.lstat(File.join(directory, name))
  end

  def file_type
    @stat.ftype
  end

  def mode
    @stat.mode
  end

  def setuid?
    @stat.setuid?
  end

  def setgid?
    @stat.setgid?
  end

  def sticky?
    @stat.sticky?
  end

  def nlink
    @stat.nlink
  end

  def owner
    Etc.getpwuid(@stat.uid).name
  end

  def group
    Etc.getgrgid(@stat.gid).name
  end

  def size
    @stat.size
  end

  def mtime
    @stat.mtime
  end

  def blocks
    @stat.blocks
  end

  def symlink?
    @stat.symlink?
  end

  def link_target
    File.readlink(File.join(@directory, @name)) if symlink?
  end
end
