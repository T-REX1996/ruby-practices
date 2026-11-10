# frozen_string_literal: true

class LongFormat
  HALF_YEAR_DAYS = 180

  FILE_TYPES = {
    'file' => '-',
    'directory' => 'd',
    'link' => 'l',
    'characterSpecial' => 'c',
    'blockSpecial' => 'b',
    'fifo' => 'p',
    'socket' => 's'
  }.freeze

  PERMISSIONS = %w[--- --x -w- -wx r-- r-x rw- rwx].freeze

  def initialize(file_entries)
    @file_entries = file_entries
  end

  def render
    return '' if @file_entries.empty?

    rows = @file_entries.map { |file_entry| build_row(file_entry) }
    widths = %i[nlink owner group size].to_h do |key|
      [key, rows.map { |row| row[key].length }.max]
    end
    formatted_rows = rows.map { |row| format_row(row, widths) }
    ["total #{@file_entries.total_blocks}", *formatted_rows].join("\n")
  end

  private

  def build_row(file_entry)
    {
      mode: format_mode(file_entry),
      nlink: file_entry.nlink.to_s,
      owner: file_entry.owner,
      group: file_entry.group,
      size: file_entry.size.to_s,
      mtime: format_mtime(file_entry.mtime),
      name: format_name(file_entry)
    }
  end

  def format_row(row, widths)
    [
      row[:mode],
      row[:nlink].rjust(widths[:nlink]),
      row[:owner].ljust(widths[:owner]),
      row[:group].ljust(widths[:group]),
      row[:size].rjust(widths[:size]),
      row[:mtime],
      row[:name]
    ].join(' ')
  end

  def format_mode(file_entry)
    owner = apply_special_bit(permission_at(file_entry.mode, 6), file_entry.setuid?, 's')
    group = apply_special_bit(permission_at(file_entry.mode, 3), file_entry.setgid?, 's')
    other = apply_special_bit(permission_at(file_entry.mode, 0), file_entry.sticky?, 't')
    FILE_TYPES.fetch(file_entry.file_type) + owner + group + other
  end

  def permission_at(mode, shift)
    PERMISSIONS[(mode >> shift) & 0o7]
  end

  def apply_special_bit(chars, enabled, special_char)
    return chars unless enabled

    execute_char = chars[2] == 'x' ? special_char : special_char.upcase
    chars[0, 2] + execute_char
  end

  def format_mtime(mtime)
    mtime > half_year_ago ? mtime.strftime('%b %e %H:%M') : mtime.strftime('%b %e  %Y')
  end

  def half_year_ago
    @half_year_ago ||= Time.now - (60 * 60 * 24 * HALF_YEAR_DAYS)
  end

  def format_name(file_entry)
    file_entry.symlink? ? "#{file_entry.name} -> #{file_entry.link_target}" : file_entry.name
  end
end
