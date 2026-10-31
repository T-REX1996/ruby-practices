# frozen_string_literal: true

class ShortFormat
  def initialize(file_list, column_count: 3)
    @file_list = file_list
    @column_count = column_count
  end

  def render
    return '' if @file_list.empty?

    columns = build_columns
    width = @file_list.max_width(:name) + 2
    row_count = columns.map(&:size).max
    Array.new(row_count) { |row| build_line(columns, row, width) }.join("\n")
  end

  private

  def build_columns
    row_count = (@file_list.count.to_f / @column_count).ceil
    @file_list.names.each_slice(row_count).to_a
  end

  def build_line(columns, row, width)
    columns.map { |column| column[row].to_s.ljust(width) }.join.rstrip
  end
end
