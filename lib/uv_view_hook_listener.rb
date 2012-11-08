require 'uv_syntax_highlighting'

class UVViewHookListener < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context = {})
    return stylesheet_link_tag(UvSyntaxHighlighting.user_theme, :plugin => 'redmine_ultraviolet')
  end
end
