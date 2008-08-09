# SpamFilter

require 'spam_filter_result'

class SpamFilter

  class << self
    @kind = nil

    attr_accessor :kind

    def instance
      return @kind.new
    end
  end

  protected
  def model_to_text(obj, fields)
    res = ""
    sfields = fields.collect { |f| f.to_s }
    sfields.sort.each do |k|
      res << "#{k.to_s.capitalize}: #{obj.send(k)}\n"
    end
    return res
  end

end

require 'spam_filter_spamc'
require 'spam_filter_none'
