require 'redmine'


Redmine::Plugin.register :redmine_ultraviolet do
  name "Redmine Ultraviolet Syntax highlighting plugin"
  author "Chris Gahan"
  description "Uses Textmate's syntaxes highlighters to highlight files in the source code repository."
  version "0.0.3"
end

# Patches
if Rails::VERSION::MAJOR >= 5
  reload_object = ActiveSupport::Reloader
else
  reload_object = ActionDispatch::Callbacks
end

reload_object.to_prepare do
  # .. to uv gem itself
  require_dependency 'uv_extension'
  require_dependency 'uv_syntax_highlighting'
  require_dependency 'uv_view_hook_listener'
  # Ensure we are always using our highlighter
  Redmine::SyntaxHighlighting.highlighter = 'UvSyntaxHighlighting'
  Uv.init_syntaxes
end

# Create or update a user custom field to hold user preference theme
if UserCustomField.table_exists?
  custom_field = UserCustomField.find_by_name(UvSyntaxHighlighting::CUSTOM_FIELD_NAME)
  unless custom_field
    UserCustomField.create(
      :name             => UvSyntaxHighlighting::CUSTOM_FIELD_NAME,
      :default_value    => UvSyntaxHighlighting.default_theme,
      :possible_values  => UvSyntaxHighlighting.all_themes,
      :field_format     => 'list',
      :is_required      => true
    )
  else
    # Keep in sync with available themes
    custom_field.default_value = UvSyntaxHighlighting.default_theme
    custom_field.possible_values = UvSyntaxHighlighting.all_themes
    custom_field.save if custom_field.changed?
  end
end
