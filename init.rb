require 'redmine'
require 'dispatcher'
require_dependency 'uv_syntax_highlighting'
require_dependency 'uv_view_hook_listener'

Redmine::Plugin.register :redmine_ultraviolet do
  name "Redmine Ultraviolet Syntax highlighting plugin"
  author "Chris Gahan"
  description "Uses Textmate's syntaxes highlighters to highlight files in the source code repository."
  version "0.0.3"

  if UserCustomField.table_exists?

    # Copy theme stylesheets
    css_directory = File.join(Engines.public_directory, 'redmine_ultraviolet', 'stylesheets')
    Uv.path.each do |dir|
      Engines.mirror_files_from File.join( dir, "render", "xhtml", "files", "css" ), css_directory
    end

    # Create or update a user custom field to hold user preference theme
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

    # Ensure we are always using our highlighter
    Dispatcher.to_prepare do
      Redmine::SyntaxHighlighting.highlighter = 'UvSyntaxHighlighting'
    end

  end

end
