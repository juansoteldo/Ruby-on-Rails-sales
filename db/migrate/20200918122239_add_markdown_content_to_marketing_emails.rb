class AddMarkdownContentToMarketingEmails < ActiveRecord::Migration[5.2]
  def change
    add_column :marketing_emails, :markdown_content, :text
    remove_column :marketing_emails, :template_path, :string
  end
end
