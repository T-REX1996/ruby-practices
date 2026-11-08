#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require_relative 'lib/file_list'
require_relative 'lib/short_format'
require_relative 'lib/long_format'

def main
  options = ARGV.getopts('alr')
  file_entries = FileList.build(Dir.pwd, all: options['a'], reverse: options['r'])
  format = options['l'] ? LongFormat.new(file_entries) : ShortFormat.new(file_entries)
  output = format.render
  puts output unless output.empty?
end

main if __FILE__ == $PROGRAM_NAME
