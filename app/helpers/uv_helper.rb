require 'uv'
require_dependency 'uv_syntax_highlighting'

module UvHelper

  def uv_user_theme()
    UvSyntaxHighlighting.user_theme
  end

end

ActionView::Base.send :include, UvHelper
