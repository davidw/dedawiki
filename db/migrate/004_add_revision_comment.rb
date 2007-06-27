class AddRevisionComment < ActiveRecord::Migration
  def self.up
    add_column 'revisions', 'comment', :string
  end

  def self.down
    remove_column 'revisions', 'comment'
  end
end
