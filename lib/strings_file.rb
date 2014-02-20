
class StringsFile
  def self.parse(file)
    Parser.new(file)
  end

  class Parser

    TRAILING_QUOTE    = /"\z/
    NON_ESCAPED_QUOTE = /[^\\]"/
    SLASH_STAR        = Regexp.escape("/*")
    COMMENT_START     = %r[#{SLASH_STAR}\z]
    TEXT_END          = %r[(#{SLASH_STAR}|\z)]
    COMMENT_END       = Regexp.new(Regexp.escape("*/"))

    # initialize with an IO object - we're mostly going to be
    # creating these from file uploads so best to just deal with the
    # tmpfile instances this gives us
    def initialize(file)
      @file = reopen_with_utf16_encoding(file)
    end

    def reopen_with_utf16_encoding(file)
      File.open(file.path, 'rb:BOM|UTF-16LE:UTF-8')
    end

    def keys
      strings.keys
    end

    def values
      strings.values
    end

    def to_a
      strings.to_a
    end

    def to_hash
      strings.dup
    end

    def each(&block)
      strings.each(&block)
    end

    def strings
      @strings ||= parse_file
    end

    def parse_file
      strings = {}
      lines.each do |line|
        key, value = parse_line(line)
        strings[key] = value unless key.nil?
      end
      strings
    end

    def parse_line(line)
      return [nil, nil] if line.empty?
      scanner = StringScanner.new(line)
      scanner.skip_until(/"/)
      key = scanner.scan_until(NON_ESCAPED_QUOTE).gsub(TRAILING_QUOTE, '')
      scanner.skip(/\s*=\s*"/)
      value = scanner.scan_until(NON_ESCAPED_QUOTE).gsub(TRAILING_QUOTE, '')
      [key, value].map { |s| s.encode(Encoding::UTF_8)}
    end

    def lines
      file_text_without_comments.split(/(\n|\r)/).map { |l| l.strip }
    end

    def file_text_without_comments
      scanner = StringScanner.new(source)
      contents = []
      begin
        text = scanner.scan_until(TEXT_END)
        contents << text.gsub(COMMENT_START, '')
        scanner.skip_until(COMMENT_END)
      end until scanner.eos?
      contents << scanner.rest
      contents.join('').strip
    end

    def source
      @source ||= @file.read
    end
  end
end