class AddCommentEmailNotification < ActiveRecord::Migration
  def self.up
    add_column :comments, 'emailupdates', :boolean
  end

  def self.down
    remove_column :comments, 'emailupdates'
  end
end
