# frozen_string_literal: true

class LongFormat
  def initialize(file_list)
    @file_list = file_list
    @widths = {}
  end

  def render
    return '' if @file_list.empty?

    lines = @file_list.map { |entry| build_line(entry) }
    ["total #{@file_list.total_blocks}", *lines].join("\n")
  end

  private

  def build_line(entry)
    [
      "#{entry.mode_text} #{entry.nlink.rjust(width(:nlink))}",
      entry.owner.ljust(width(:owner)),
      entry.group.ljust(width(:group)),
      entry.size.rjust(width(:size)),
      entry.mtime_text,
      entry.display_name
    ].join(' ')
  end

  def width(attribute)
    @widths[attribute] ||= @file_list.max_width(attribute)
  end
end
