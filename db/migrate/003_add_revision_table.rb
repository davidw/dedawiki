class AddRevisionTable < ActiveRecord::Migration
  def self.up
    create_table "revisions" do |t|
      t.column "page_id", :integer, :default => 0, :null => false
      t.column "user_id", :integer, :null => false
      t.column "ip", :string, :limit => 60
      t.column "created_at", :datetime, :null => false
      t.column "updated_at", :datetime, :null => false
      t.column "content", :text
      t.column 'addchars', :integer
      t.column 'delchars', :integer
    end
  end

  def self.down
    drop_table "revisions"
  end
end
