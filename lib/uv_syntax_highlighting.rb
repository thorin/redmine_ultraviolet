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

module UvSyntaxHighlighting

  CUSTOM_FIELD_NAME = 'Ultraviolet Theme'

  class << self
    # Highlights +text+ as the content of +filename+
    # Should not return line numbers nor outer pre tag
    def highlight_by_filename(text, filename)
      language = Uv.syntax_for_text(text, filename)
      language ? highlight_by_language(text, language) : ERB::Util.h(text)
    end

    # Highlights +text+ using +language+ syntax
    # Should not return outer pre tag
    def highlight_by_language(text, language)
      if not Uv.syntaxes.include? language then
        Rails.logger.warn "Unknown syntax #{language}"
        return ERB::Util.h(text)
      end
      xhtml = Uv.parse(text, "xhtml", language, false, user_theme)
      Rails.logger.info "Highlighting for language #{language} with theme #{user_theme}"
      Rails.logger.info "Input:\n#{text}"
      Rails.logger.info "Output:\n#{xhtml}"
      xhtml.gsub /^<pre class=".+?">(.*)<\/pre>$/m, '\1'
    rescue => ex
      Rails.logger.warn "Error in redmine_ultraviolet during #{language} parsing: #{ex}"
      ERB::Util.h(text)
    end

    def user_theme()
      custom_value = User.current.custom_value_for(custom_field)
      if custom_value and Uv.themes.include?(custom_value.value) then
        custom_value.value
      else
        default_theme
      end
    end

    def all_themes()
      Uv.themes.sort
    end

    def default_theme()
      all_themes.first
    end

  private

    def custom_field()
      UserCustomField.find_by_name(CUSTOM_FIELD_NAME)
    end

  end
end
