class AddPageTable < ActiveRecord::Migration
  # modify the table name for now, until I can figure out how to set it w/ the generator
  def self.up
    create_table "pages" do |t|
      t.column "title", :string, :null => false
      t.column "content", :text
      t.column "content_html", :text
      t.column "created_at", :datetime
      t.column "locked_by", :integer
    end
  end

  def self.down
    drop_table "pages"
  end
end
