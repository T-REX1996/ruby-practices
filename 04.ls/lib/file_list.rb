# frozen_string_literal: true

require 'forwardable'
require_relative 'file_entry'

class FileList
  extend Forwardable
  include Enumerable

  def_delegators :@file_entries, :each, :empty?

  def self.build(directory, all: false, reverse: false)
    names = Dir.entries(directory).sort
    names = names.reject { |name| name.start_with?('.') } unless all
    names = names.reverse if reverse
    file_entries = names.map { |name| FileEntry.new(directory, name) }
    new(file_entries)
  end

  def initialize(file_entries)
    @file_entries = file_entries
  end

  def names
    map(&:name)
  end

  # File::Stat#blocks は 512 バイト単位。ls の total は 1024 バイト単位なので 2 で割る
  def total_blocks
    sum(&:blocks) / 2
  end
end
