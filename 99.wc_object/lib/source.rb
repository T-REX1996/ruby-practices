# frozen_string_literal: true

class Source
  attr_reader :path

  def initialize(path)
    @path = path
  end

  def stdin?
    @path.nil?
  end

  def read
    stdin? ? $stdin.read : File.read(@path)
  end
end
