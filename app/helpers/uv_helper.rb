require 'uv'
require_dependency 'uv_syntax_highlighting'

module UvHelper

  def uv_user_theme()
    UvSyntaxHighlighting.user_theme || Uv.themes.sort.first
  end

end

ActionView::Base.send :include, UvHelper
