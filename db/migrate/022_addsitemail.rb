class Addsitemail < ActiveRecord::Migration
  def self.up
    add_column 'siteinfos', 'email', :string
  end

  def self.down
    remove_column 'siteinfos', 'email'
  end
end
