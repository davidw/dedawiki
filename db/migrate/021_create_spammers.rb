class CreateSpammers < ActiveRecord::Migration
  def self.up
    create_table :spammers do |t|
      t.column :ip, :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :spammers
  end
end
