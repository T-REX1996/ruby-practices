# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/file_list'
require_relative '../lib/long_format'

class LongFormatTest < Minitest::Test
  ONE_DAY = 60 * 60 * 24

  def test_mtime_within_half_year_shows_time
    in_tmpdir do |dir|
      mtime = Time.now - (ONE_DAY * 179)
      create_file(dir, 'recent.txt', mtime)

      assert_match(/ #{mtime.strftime('%b %e %H:%M')} recent\.txt$/, render_line(dir, 'recent.txt'))
    end
  end

  def test_mtime_older_than_half_year_shows_year
    in_tmpdir do |dir|
      mtime = Time.now - (ONE_DAY * 181)
      create_file(dir, 'old.txt', mtime)

      assert_match(/ #{mtime.strftime('%b %e  %Y')} old\.txt$/, render_line(dir, 'old.txt'))
    end
  end

  def test_symlink_shows_link_target
    in_tmpdir do |dir|
      create_file(dir, 'target.txt', Time.now)
      File.symlink('target.txt', File.join(dir, 'link'))

      line = render_line(dir, 'link')

      assert line.start_with?('l')
      assert line.end_with?(' link -> target.txt')
    end
  end

  def test_regular_file_does_not_show_link_target
    in_tmpdir do |dir|
      create_file(dir, 'target.txt', Time.now)

      assert render_line(dir, 'target.txt').end_with?(' target.txt')
    end
  end

  private

  def in_tmpdir(&block)
    Dir.mktmpdir(&block)
  end

  def create_file(dir, name, mtime)
    path = File.join(dir, name)
    File.write(path, '')
    File.utime(mtime, mtime, path)
  end

  def render_line(dir, name)
    output = LongFormat.new(FileList.build(dir)).render
    output.lines(chomp: true).find { |line| line.include?(name) }
  end
end
