class AddConfirmToRevision < ActiveRecord::Migration
  def self.up
    add_column :revisions, :confirmed, :boolean
  end

  def self.down
    remove_column :revisions, :confirmed
  end
end
