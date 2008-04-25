class AddSpamToRevision < ActiveRecord::Migration
  def self.up
    add_column :revisions, 'spam', :boolean
    add_column :revisions, 'spaminess', :integer
  end

  def self.down
    remove_column :revisions, 'spam'
    remove_column :revisions, 'spaminess'
  end
end
