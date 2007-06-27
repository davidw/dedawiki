class AddAnonUser < ActiveRecord::Migration
  def self.up
    u = User.new(:login => 'anonymous',
                 :email => 'foo@bar.com',
                 :myurl => '/',
                 :name => 'Anonymous',
                 :aboutme => 'DedaWiki Anonymous User')
    pw = rand.to_s + rand.to_s
    u.password = pw
    u.password_confirmation = pw
    u.save!
  end

  def self.down
    u = User.find_by_login('anonymous')
    u.destroy
  end
end
