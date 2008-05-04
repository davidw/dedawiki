class ModifySpaminess < ActiveRecord::Migration
  def self.up
    change_column :revisions, 'spaminess', :float
  end

  def self.down
    change_column :revisions, 'spaminess', :integer
  end
end
