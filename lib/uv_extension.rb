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

  def Uv.unalias(language)
    init_aliases unless @aliases
    Rails.logger.debug "redmine_ultraviolet: known syntaxes: #{@aliases}" if @aliases[language].blank?
    @aliases[language] || @aliases["source.#{language}"]
  end

  def Uv.init_aliases()
    init_syntaxes unless @syntaxes
    @aliases = {}
    @syntaxes.each_pair do |name, s|
      @aliases[name] = name
      if s.fileTypes then
        s.fileTypes.each do |t|
          @aliases[t] = name
        end
      end
    end
  end

  # Removed from Uv but there are still references to it in the gem
  #
  # So we restore the method manually and call it from the init.rb of redmine
  # Adapted from: http://www.ruby-doc.org/gems/docs/b/bjeanes-ultraviolet-0.10.3/Uv.html
  def Uv.init_syntaxes
    @syntaxes = {}
    Dir.glob( File.join(syntax_path, '*.syntax') ).each do |f|
      name = File.basename(f, '.syntax')
      @syntaxes[name] = Textpow::SyntaxNode.load( f )
    end
    Rails.logger.debug "redmine_ultraviolet: finished importing syntaxes: #{@syntaxes}"
  end

end
Uv.send :include, UvExtension

