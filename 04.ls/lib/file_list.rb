# frozen_string_literal: true

require_relative 'file_entry'

class FileList
  include Enumerable

  def self.build(directory, all: false, reverse: false)
    names = Dir.entries(directory).sort
    names = names.reject { |name| name.start_with?('.') } unless all
    names = names.reverse if reverse
    new(names.map { |name| FileEntry.new(directory, name) })
  end

  def initialize(entries)
    @entries = entries
  end

  def each(&block)
    @entries.each(&block)
  end

  def empty?
    @entries.empty?
  end

  def names
    map(&:name)
  end

  # File::Stat#blocks は 512 バイト単位。ls の total は 1024 バイト単位なので 2 で割る
  def total_blocks
    sum(&:blocks) / 2
  end

  def max_width(attribute)
    map { |entry| entry.public_send(attribute).length }.max
  end
end
