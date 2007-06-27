class AddAboutMe < ActiveRecord::Migration
  def self.up
    add_column 'users', 'name', :string
    add_column 'users', 'myurl', :string
    add_column 'users', 'aboutme', :text
  end

  def self.down
    remove_column 'users', 'name'
    remove_column 'users', 'myurl'
    remove_column 'users', 'aboutme'
  end
end
