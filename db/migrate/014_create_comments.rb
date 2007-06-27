class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.column :content, :text
      t.column :user_id, :integer, :null => false
      t.column :page_id, :integer, :null => false
      t.column :parent_id, :integer
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end
  end

  def self.down
    drop_table :comments
  end
end
