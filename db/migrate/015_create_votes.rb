class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.column :score, :integer
      t.column :comment_id, :integer
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :votes
  end
end
