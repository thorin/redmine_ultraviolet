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
    @aliases[language]
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

end
Uv.send :include, UvExtension

