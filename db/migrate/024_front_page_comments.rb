class FrontPageComments < ActiveRecord::Migration
  def self.up
    add_column 'siteinfos', 'frontpagecomments', :boolean
  end

  def self.down
    remove_column 'siteinfos', 'frontpagecomments'
  end
end
