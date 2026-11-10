# frozen_string_literal: true

class Counts
  attr_reader :name, :lines, :words, :bytes

  def self.from_text(name, text)
    new(name, text.count("\n"), text.split.size, text.bytesize)
  end

  def self.total(counts_list)
    new('total', counts_list.sum(&:lines), counts_list.sum(&:words), counts_list.sum(&:bytes))
  end

  def initialize(name, lines, words, bytes)
    @name = name
    @lines = lines
    @words = words
    @bytes = bytes
  end

  def format(keys, width)
    columns = keys.map { |key| public_send(key).to_s.rjust(width) }
    columns << name if name
    columns.join(' ')
  end
end
