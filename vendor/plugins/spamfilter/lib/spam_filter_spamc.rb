require 'spamc'

class SpamFilterSpamc < SpamFilter
  include SpamAssassin

  def initialize()
    @filter = SpamC.new
  end

  def check(obj, *fields)
    spam_filter_result(@filter.symbols(model_to_text(obj, fields)))
  end

  def spam(obj, *fields)
    @filter.is_spam(model_to_text(obj, fields))
  end

  def ham(obj, *fields)
    @filter.is_ham(model_to_text(obj, fields))
  end

  private
  def spam_filter_result(saresult)
    sfr = SpamFilterResult.new
    sfr.spam = saresult.spam?
    sfr.spaminess = saresult.score.to_f / saresult.threshold.to_f
    return sfr
  end

end

