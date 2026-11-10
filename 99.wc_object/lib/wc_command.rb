# frozen_string_literal: true

require_relative 'options'
require_relative 'source'
require_relative 'counts'

class WcCommand
  STDIN_WIDTH = 7

  def initialize(argv)
    @options = Options.parse(argv)
  end

  def run
    sources = build_sources
    counts_list = read_counts_list(sources)
    width = decide_width(counts_list, from_stdin: sources.first.stdin?)

    counts_list.each { |counts| puts counts.format(@options.keys, width) }
    puts Counts.total(counts_list).format(@options.keys, width) if counts_list.size > 1
  end

  private

  def build_sources
    paths = @options.paths
    paths.empty? ? [Source.new(nil)] : paths.map { |path| Source.new(path) }
  end

  def read_counts_list(sources)
    sources.filter_map do |source|
      Counts.from_text(source.path, source.read)
    rescue SystemCallError
      warn "wc: #{source.path}: No such file or directory"
      nil
    end
  end

  def decide_width(counts_list, from_stdin:)
    keys = @options.keys
    return STDIN_WIDTH if from_stdin && keys.size > 1
    return 0 if keys.size == 1 && counts_list.size <= 1

    Counts.total(counts_list).bytes.to_s.size
  end
end
