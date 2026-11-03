# frozen_string_literal: true

require_relative 'counts'

class Formatter
  STDIN_WIDTH = 7

  def initialize(keys, counts_list, from_stdin:)
    @keys = keys
    @width = decide_width(counts_list, from_stdin)
  end

  def format_row(counts, name)
    columns = @keys.map { |key| counts.value_for(key).to_s.rjust(@width) }
    columns << name if name
    columns.join(' ')
  end

  private

  def decide_width(counts_list, from_stdin)
    return STDIN_WIDTH if from_stdin && @keys.size > 1
    return 0 if @keys.size == 1 && counts_list.size <= 1

    Counts.total(counts_list).bytes.to_s.size
  end
end
