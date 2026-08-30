#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_COUNT = 3

def target_files(path)
  Dir.entries(path)
     .reject { |name| name.start_with?('.') }
     .sort
end

def build_columns(files, column_count)
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

def main
  files = target_files(Dir.pwd)
  columns = build_columns(files, COLUMN_COUNT)
  print_columns(columns)
end

main if __FILE__ == $PROGRAM_NAME
