#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMN_COUNT = 3

def main
  options = parse_options(ARGV)
  files = target_files(Dir.pwd, all: options[:all])
  columns = build_columns(files, COLUMN_COUNT)
  print_columns(columns)
end

def parse_options(argv)
  options = { all: false }
  OptionParser.new do |opts|
    opts.on('-a', '--all', 'Do not ignore entries starting with .') do
      options[:all] = true
    end
  end.parse!(argv)
  options
end

def target_files(path, all: false)
  entries = Dir.entries(path)
  entries = entries.reject { |name| name.start_with?('.') } unless all
  entries.sort
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

main if __FILE__ == $PROGRAM_NAME
