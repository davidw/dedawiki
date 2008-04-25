# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 26) do

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.integer  "user_id",      :null => false
    t.integer  "page_id",      :null => false
    t.integer  "parent_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.boolean  "emailupdates"
  end

  create_table "pages", :force => true do |t|
    t.string   "title",        :null => false
    t.text     "content"
    t.text     "content_html"
    t.datetime "created_at"
    t.integer  "locked_by"
  end

  create_table "revisions", :force => true do |t|
    t.integer  "page_id",                  :default => 0, :null => false
    t.integer  "user_id",                                 :null => false
    t.string   "ip",         :limit => 60
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.text     "content"
    t.integer  "addchars"
    t.integer  "delchars"
    t.string   "comment"
    t.boolean  "spam"
    t.integer  "spaminess"
    t.boolean  "confirmed"
  end

  create_table "siteinfos", :force => true do |t|
    t.string  "name"
    t.string  "tagline"
    t.text    "template"
    t.string  "adminlogin"
    t.boolean "setup",             :default => false
    t.string  "email"
    t.boolean "frontpagecomments"
  end

  create_table "spammers", :force => true do |t|
    t.string   "ip"
    t.datetime "created_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "myurl"
    t.text     "aboutme"
    t.boolean  "admin"
  end

  create_table "votes", :force => true do |t|
    t.integer "score"
    t.integer "comment_id"
    t.integer "user_id"
  end

end
