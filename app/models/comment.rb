class Comment < ActiveRecord::Base
  acts_as_tree :order => 'created_at'

  has_many :votes

  belongs_to :user
  belongs_to :page

  after_create :mail_model
end
