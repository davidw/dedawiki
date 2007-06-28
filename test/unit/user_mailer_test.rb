require File.dirname(__FILE__) + '/../test_helper'

class UserMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  fixtures :users

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
  end

  def test_welcome
    u = User.find(1)
    @expected.subject = 'Welcome to DedaWiki'
    @expected.body    = read_fixture('welcome')
    @expected.date    = Time.now
    @expected.to = u.email

    assert_equal @expected.encoded, UserMailer.create_welcome(u).encoded
  end

  def test_forgot_password
    u = User.find(1)
    @expected.subject = 'DedaWiki: Password reset'
    @expected.body    = read_fixture('forgot_password')
    @expected.date    = Time.now
    @expected.to = u.email
    newpass = "123456"

    assert_equal(@expected.encoded,
                 UserMailer.create_forgot_password(u, newpass).encoded)
  end

  def test_changed_account_info
    @expected.subject = 'DedaWiki: Account information update'
    @expected.body    = read_fixture('changed_account_info')
    @expected.date    = Time.now

    assert_equal @expected.encoded, UserMailer.create_changed_account_info(@expected.date).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/user_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
