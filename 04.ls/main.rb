#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

COLUMN_COUNT = 3

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

def target_files(path, reverse: false)
  files = Dir.entries(path)
             .reject { |name| name.start_with?('.') }
             .sort
  reverse ? files.reverse : files
end

def build_columns(files, column_count)
  return [] if files.empty?

  row_count = (files.size.to_f / column_count).ceil
  files.each_slice(row_count).to_a
end

def print_columns(columns)
  return if columns.empty?

  width = columns.flatten.map(&:length).max + 2
  row_count = columns.map(&:size).max

  row_count.times do |row|
    line = columns.map { |column| column[row] }
                  .map { |name| name.nil? ? '' : name.ljust(width) }
                  .join
    puts line.rstrip
  end
end

def apply_special_bit(chars, enabled, special_char)
  return chars unless enabled

  chars[2] = chars[2] == 'x' ? special_char : special_char.upcase
  chars
end

def format_permissions(stat)
  mode = stat.mode
  owner, group, other = [6, 3, 0].map { |shift| PERMISSIONS[(mode >> shift) & 0o7].dup }
  apply_special_bit(owner, stat.setuid?, 's')
  apply_special_bit(group, stat.setgid?, 's')
  apply_special_bit(other, stat.sticky?, 't')
  FILE_TYPES.fetch(stat.ftype) + owner + group + other
end

def format_mtime(time)
  half_year_ago = Time.now - (60 * 60 * 24 * 180)
  time > half_year_ago ? time.strftime('%b %e %H:%M') : time.strftime('%b %e  %Y')
end

def format_name(path, name, stat)
  return name unless stat.symlink?

  "#{name} -> #{File.readlink(File.join(path, name))}"
end

def build_detail(path, name)
  stat = File.lstat(File.join(path, name))
  {
    blocks: stat.blocks,
    mode: format_permissions(stat),
    nlink: stat.nlink.to_s,
    owner: Etc.getpwuid(stat.uid).name,
    group: Etc.getgrgid(stat.gid).name,
    size: stat.size.to_s,
    mtime: format_mtime(stat.mtime),
    name: format_name(path, name, stat)
  }
end

def print_details(path, files)
  return if files.empty?

  details = files.map { |name| build_detail(path, name) }
  # File::Stat#blocks は 512 バイト単位。ls の total は 1024 バイト単位なので 2 で割る
  puts "total #{details.sum { |detail| detail[:blocks] } / 2}"

  widths = %i[nlink owner group size].to_h do |key|
    [key, details.map { |detail| detail[key].length }.max]
  end

  details.each do |detail|
    puts [
      "#{detail[:mode]} #{detail[:nlink].rjust(widths[:nlink])}",
      detail[:owner].ljust(widths[:owner]),
      detail[:group].ljust(widths[:group]),
      detail[:size].rjust(widths[:size]),
      detail[:mtime],
      detail[:name]
    ].join(' ')
  end
end

def main
  params = ARGV.getopts('lr')
  path = Dir.pwd
  files = target_files(path, reverse: params['r'])

  if params['l']
    print_details(path, files)
  else
    print_columns(build_columns(files, COLUMN_COUNT))
  end
end

main if __FILE__ == $PROGRAM_NAME
