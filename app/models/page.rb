class Page < ActiveRecord::Base
  has_many :revisions, :order => 'created_at desc', :dependent => :destroy
  has_many :comments

  before_update :regenerate_html
  before_save :regenerate_html

  private

  def regenerate_html
    self.content_html = self.content.blank? ? "" : Maruku.new(local_links(self.content)).to_html
  end

  def local_links(txt)
    # Grab [[foo bar]] style things and turn them into valid markdown.
    return txt.gsub(/\[\[([^\]]+)\]\]/) { |s|
      "[#{$1}](/page/show/#{ERB::Util.url_encode($1)})"
    }
  end

end
