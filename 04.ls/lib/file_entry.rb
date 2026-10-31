# frozen_string_literal: true

require 'etc'

class FileEntry
  HALF_YEAR_DAYS = 180

  FILE_TYPES = {
    'file' => '-',
    'directory' => 'd',
    'link' => 'l',
    'characterSpecial' => 'c',
    'blockSpecial' => 'b',
    'fifo' => 'p',
    'socket' => 's'
  }.freeze

  PERMISSIONS = %w[--- --x -w- -wx r-- r-x rw- rwx].freeze

  attr_reader :name

  def initialize(directory, name)
    @directory = directory
    @name = name
    @stat = File.lstat(File.join(directory, name))
  end

  def display_name
    @stat.symlink? ? "#{@name} -> #{File.readlink(File.join(@directory, @name))}" : @name
  end

  def mode_text
    FILE_TYPES.fetch(@stat.ftype) + owner_permission + group_permission + other_permission
  end

  def nlink
    @stat.nlink.to_s
  end

  def owner
    Etc.getpwuid(@stat.uid).name
  end

  def group
    Etc.getgrgid(@stat.gid).name
  end

  def size
    @stat.size.to_s
  end

  def mtime_text
    mtime = @stat.mtime
    mtime > half_year_ago ? mtime.strftime('%b %e %H:%M') : mtime.strftime('%b %e  %Y')
  end

  def blocks
    @stat.blocks
  end

  private

  def owner_permission
    apply_special_bit(permission_at(6), @stat.setuid?, 's')
  end

  def group_permission
    apply_special_bit(permission_at(3), @stat.setgid?, 's')
  end

  def other_permission
    apply_special_bit(permission_at(0), @stat.sticky?, 't')
  end

  def permission_at(shift)
    PERMISSIONS[(@stat.mode >> shift) & 0o7]
  end

  def apply_special_bit(chars, enabled, special_char)
    return chars unless enabled

    execute_char = chars[2] == 'x' ? special_char : special_char.upcase
    chars[0, 2] + execute_char
  end

  def half_year_ago
    Time.now - (60 * 60 * 24 * HALF_YEAR_DAYS)
  end
end
