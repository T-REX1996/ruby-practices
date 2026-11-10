# frozen_string_literal: true

class ShortFormat
  def initialize(file_entries, column_count: 3)
    @file_entries = file_entries
    @column_count = column_count
  end

  def render
    return '' if @file_entries.empty?

    columns = build_columns
    max_name_length = @file_entries.names.map(&:length).max
    width = max_name_length + 2
    row_count = columns.map(&:size).max
    Array.new(row_count) { |row_index| build_row(columns, row_index, width) }.join("\n")
  end

  private

  def build_columns
    row_count = @file_entries.count.ceildiv(@column_count)
    @file_entries.names.each_slice(row_count).to_a
  end

  def build_row(columns, row_index, width)
    columns.map { |column| column[row_index].to_s.ljust(width) }.join.rstrip
  end
end
