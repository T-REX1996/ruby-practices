# frozen_string_literal: true

require_relative 'options'
require_relative 'source'
require_relative 'counts'
require_relative 'formatter'

class WcCommand
  def initialize(argv)
    @options = Options.parse(argv)
  end

  def run
    sources = build_sources
    rows = read_rows(sources)
    counts_list = rows.map { |_, counts| counts }
    formatter = Formatter.new(@options.keys, counts_list, from_stdin: sources.first.stdin?)

    rows.each { |source, counts| puts formatter.format_row(counts, source.path) }
    puts formatter.format_row(Counts.total(counts_list), 'total') if rows.size > 1
  end

  private

  def build_sources
    paths = @options.paths
    paths.empty? ? [Source.new(nil)] : paths.map { |path| Source.new(path) }
  end

  def read_rows(sources)
    sources.filter_map do |source|
      [source, Counts.from_text(source.read)]
    rescue SystemCallError
      warn "wc: #{source.path}: No such file or directory"
      nil
    end
  end
end
