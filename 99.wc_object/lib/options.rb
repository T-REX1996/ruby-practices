# frozen_string_literal: true

require 'optparse'

class Options
  KEY_BY_OPTION = { 'l' => :lines, 'w' => :words, 'c' => :bytes }.freeze
  DEFAULT_KEYS = %i[lines words bytes].freeze

  attr_reader :keys, :paths

  def self.parse(argv)
    argv = argv.dup
    flags = OptionParser.new.getopts(argv, 'lwc')
    new(flags, argv)
  end

  def initialize(flags, paths)
    selected = KEY_BY_OPTION.select { |option, _| flags[option] }.values
    @keys = selected.empty? ? DEFAULT_KEYS : selected
    @paths = paths
  end
end
