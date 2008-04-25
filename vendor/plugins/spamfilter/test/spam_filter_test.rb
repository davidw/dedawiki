require 'test/unit'

$LOAD_PATH << File.dirname(__FILE__) + '/../lib/'

require 'spam_filter'

# Mock object
class Page
  attr_accessor :id, :title, :content
end

class SpamFilterTest < Test::Unit::TestCase

  def setup
    @spam = Page.new
    @spam.title = '5202C'
    @spam.content = 'Cheap cialis online
<a href="https://www.blogger.com/comment.g?blogID=4988977323387838376&postID=3796459452222662384">cialis</a>
https://www.blogger.com/comment.g?blogID=4988977323387838376&postID=3796459452222662384
[url=https://www.blogger.com/comment.g?blogID=4988977323387838376&postID=3796459452222662384]cialis[/url]'


    @ham = Page.new
    @ham.title = '5202C'
    @ham.content = 'Manufacturer: AzureWave
 
Model number: AD-TU200
 
Chipset: 7047
 
PCI id:
 
Reason (no specs from manufacturer, really new hardware, etc): Functionality (from 0 to 100% of full functionality): 0% - Shows up in HAL Device Manager (GNOME) but only as a raw USB device
 
URL for more information:
 
Bugzilla # for kernel bugs database:
 
Contact (your email):
 
Notes: Tested on Ubuntu 7.10

Recommended alternatives:'


  end

  # Replace this with your real tests.
  def test_check
    s = SpamFilter.instance
    res = s.check @spam, :title, :content
    assert res.spam
    puts res.inspect
  end

  def test_check_twice
    s = SpamFilter.instance
    res = s.check @spam, :title, :content
    assert_equal res.spam, true
    res = s.check @spam, :title, :content
    assert_equal res.spam, true
    puts res.inspect
  end

  def test_tell_spam
    s = SpamFilter.instance
    res = s.spam @spam, :title, :content
    puts res.inspect
  end

  def test_ham
    s = SpamFilter.instance
    res = s.check @ham, :title, :content
    puts res.inspect
    assert_equal res.spam, false
  end

end
