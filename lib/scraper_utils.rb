require "pathname"

class ScraperUtils

  if RUBY_PLATFORM =~ /mswin/
    PATH_SPLIT_RE = /[\/\\]/
  else
    PATH_SPLIT_RE = /\//
  end

  def self.path_to_uri(file_path)
    unless file_path.nil?
      result = 'file://'
      segments = file_path.split PATH_SPLIT_RE
      index = 0

      segments.each do |segment|
        next if segment == '' && index == 0
        segment = escape_segment(segment)
        result += '/'
        result += segment
        ++index
      end

      result
    end
  end

  def self.normalize_path(path)
    Pathname.new(path).expand_path.to_s
  end

  private

  def self.escape_segment(string)
    string.gsub(/([^a-zA-Z0-9_.:-]+)/n) do
      '%' + $1.unpack('H2' * $1.size).join('%').upcase
    end
  end

end