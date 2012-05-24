require 'uv'

module UvExtension

  def Uv.syntax_for_text(text, filename)
    init_syntaxes unless @syntaxes

    basename = File.basename(filename)
    extname = File.extname(filename)[1..-1]
    first_line = text.lines.find { |line| line.strip.size > 0 }

    @syntaxes.find do |name, syntax|
      if syntax.fileTypes
        return name if syntax.fileTypes.include?(extname) || syntax.fileTypes.include?(basename)
      end
      return name if syntax.firstLineMatch && syntax.firstLineMatch =~ first_line
    end
  end

end
Uv.send :include, UvExtension

class UvSyntaxHighlighting

  CUSTOM_FIELD_NAME = 'Ultraviolet Theme'

  # Highlights +text+ as the content of +filename+
  # Should not return line numbers nor outer pre tag
  def self.highlight_by_filename(text, filename)
    language = Uv.syntax_for_text(text, filename)
    language ? highlight_by_language(text, language) : ERB::Util.h(text)
  end

  # Highlights +text+ using +language+ syntax
  # Should not return outer pre tag
  def self.highlight_by_language(text, language)
    xhtml = Uv.parse(text, "xhtml", language, false, user_theme)
    xhtml.gsub /^<pre class=".+?">(.*)<\/pre>$/m, '\1'
  rescue => ex
    Rails.logger.warn "Error in redmine_ultraviolet during #{language} parsing: #{ex}"
    ERB::Util.h(text)
  end

  def self.user_theme()
    theme = User.current.custom_value_for(custom_field).value
    Uv.themes.include?(theme) ? theme : Uv.themes.sort.first
  end

private

  def self.custom_field()
    UserCustomField.find_by_name(CUSTOM_FIELD_NAME)
  end

end
