#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

STDIN_WIDTH = 7

def count_text(text)
  {
    lines: text.count("\n"),
    words: text.split.size,
    bytes: text.bytesize
  }
end

def selected_keys(options)
  keys = { 'l' => :lines, 'w' => :words, 'c' => :bytes }
         .select { |option, _| options[option] }
         .values
  keys.empty? ? %i[lines words bytes] : keys
end

def format_row(counts, keys, width, label)
  columns = keys.map { |key| counts[key].to_s.rjust(width) }
  columns << label if label
  columns.join(' ')
end

def total_counts(rows)
  %i[lines words bytes].to_h do |key|
    [key, rows.sum { |_, counts| counts[key] }]
  end
end

def read_file_rows(paths)
  paths.filter_map do |path|
    [path, count_text(File.read(path))]
  rescue SystemCallError
    warn "wc: #{path}: No such file or directory"
    nil
  end
end

def column_width(rows, keys)
  return 0 if keys.size == 1 && rows.size == 1

  total_counts(rows)[:bytes].to_s.size
end

def main
  options = ARGV.getopts('lwc')
  keys = selected_keys(options)

  if ARGV.empty?
    counts = count_text($stdin.read)
    puts format_row(counts, keys, keys.size == 1 ? 0 : STDIN_WIDTH, nil)
    return
  end

  rows = read_file_rows(ARGV)
  width = column_width(rows, keys)
  rows.each { |path, counts| puts format_row(counts, keys, width, path) }
  puts format_row(total_counts(rows), keys, width, 'total') if rows.size > 1
end

main
