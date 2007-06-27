module Differ

  class DifferClass

    def initialize(oldhtml, newhtml)
      @odoc = REXML::Document.new
      @odoc << (REXML::Element.new 'html')
      @odoc.root << (body = REXML::Element.new 'body')
      @xhtmldiff = XHTMLDiff.new(body)

      a = REXML::HashableElementDelegator.new(REXML::XPath.first(REXML::Document.new("<html><body>" + oldhtml + "</body></html>"), '/html/body'))
      b = REXML::HashableElementDelegator.new(REXML::XPath.first(REXML::Document.new("<html><body>" + newhtml + "</body></html>"), '/html/body'))

      Diff::LCS.traverse_balanced(a, b, @xhtmldiff)
    end

    def diffs()
      buf = @odoc.to_s

      buf.gsub!('<ins>', '<div class="ins">')
      buf.gsub!('</ins>', '</div>')
      buf.gsub!('<del>', '<div class="del">')
      buf.gsub!('</del>', '</div>')

      buf.gsub!('<insspan>', '<span class="ins">')
      buf.gsub!('</insspan>', '</span>')
      buf.gsub!('<delspan>', '<span class="del">')
      buf.gsub!('</delspan>', '</span>')

      return buf
    end

    def added
      return @xhtmldiff.add
    end

    def deleted
      return @xhtmldiff.del
    end
  end
end
