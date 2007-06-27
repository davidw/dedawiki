class Siteinfo < ActiveRecord::Base

  @@cached = nil
  @@setup_complete = nil

  # Return the main site instance.  For now there is only one.
  def Siteinfo.main
    return @@cached unless @@cached.nil?
    @@cached = Siteinfo.find(:first)
    if @@cached.nil?
      @@cached = Siteinfo.new(:name => "Need to configure this", :tagline => 'no tagline yet')
    end
    return @@cached
  end

  # This needs to be efficient, because it needs to check each time
  # whether it's true.
  def Siteinfo.setup?
    return @@setup_complete unless @@setup_complete.nil?

    @@setup_complete = Siteinfo.find(:first)
    if @@setup_complete.nil?
      @@setup_complete = false
    end
    return @@setup_complete
  end

  # Let the system know that the site has indeed been configured.
  def Siteinfo.setup!
    @@setup_complete = true
    si = Siteinfo.find(:first)
    si.setup = true
    si.save!
  end

end
