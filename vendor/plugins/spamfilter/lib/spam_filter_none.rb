require 'spamc'

# No filter.

class SpamFilterNone < SpamFilter
  include SpamAssassin

  def initialize()
  end

  def check(obj, *fields)
    return spam_filter_result()
  end

  def spam(obj, *fields)
    return false
  end

  def ham(obj, *fields)
    return true
  end

  private
  def spam_filter_result()
    sfr = SpamFilterResult.new
    sfr.spam = false
    sfr.spaminess = 0
    return sfr
  end

end

# Default!
SpamFilter.kind = SpamFilterNone
