class AddAllowAnonFlag < ActiveRecord::Migration
  def self.up
    add_column 'siteinfos', 'allowanonymous', :boolean
  end

  def self.down
    remove_column 'siteinfos', 'allowanonymous'
  end
end
