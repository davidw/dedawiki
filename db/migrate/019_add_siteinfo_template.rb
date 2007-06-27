class AddSiteinfoTemplate < ActiveRecord::Migration
  def self.up
    add_column 'siteinfos', 'template', :text
    add_column 'siteinfos', 'adminlogin', :string
    add_column 'siteinfos', 'setup', :boolean, :default => false
  end

  def self.down
    remove_column 'siteinfos', 'template'
    remove_column 'siteinfos', 'adminlogin'
    remove_column 'siteinfos', 'setup'
  end
end
