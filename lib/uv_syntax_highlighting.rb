require 'uv'

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
      syntax = Uv.unalias(language)
      if syntax then
        xhtml = Uv.parse(text, "xhtml", syntax, false, user_theme)
        xhtml.gsub /^<pre class=".+?">(.*)<\/pre>$/m, '\1'
      else
        Rails.logger.warn "redmine_ultraviolet: unknown syntax #{language}"
        ERB::Util.h(text)
      end
    rescue => ex
      Rails.logger.error "redmine_ultraviolet: error during #{language} parsing: #{ex}"
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
      unless @themes
        @themes = Dir.glob( File.join(File.dirname(__FILE__), '..', 'assets', 'stylesheets', '*.css') ).collect do |f|
          File.basename(f, '.css')
        end
        @themes.sort!
      end
      @themes
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

