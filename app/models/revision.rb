class Revision < ActiveRecord::Base
  belongs_to :page
  belongs_to :user
end
