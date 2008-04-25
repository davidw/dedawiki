#
#= SpamAssassin Ruby Module
#
#This module provides services to Spamassassin's spamd daemon, by
#using the protocol used by spamc.  This is useful if you have a long
#running ruby program that will need to make many calls to spamd.
#
#== Usage
#
# include SpamAssassin
#
# sa = SpamC.new("localhost", 783)
# result = sa.symbols(message)
#
# if result.spam?
#   print result
# end
#
#== Author / LICENSE
# Copyright (2005) David Morton <mortonda@dgrmm.net>
#  Licensed under the Academic Free License version 2.1
#  http://www.opensource.org/licenses/afl-2.1.php
#
module SpamAssassin
  require "socket"
  require 'timeout'

  class SpamC
    #intialize takes 3 option parameters:
    # host: hostname of spamd daemon
    # port: port of spamd daemon
    # timeout: option timeout (in seconds) that the operation should complete in
    def initialize (host="localhost", port=783, timeout=30)
      @port = port
      @host=host
      @timeout = timeout
      @s =  TCPsocket.open(@host, @port)
    end

    public

    #FIXME
    #connect to the spamd server.  Currenty uneeded, as initialize does this too.
    #perhaps this will be usefull in loger running programs.
    def connect()
      @s = @s || TCPsocket.open(@host, @port)
    end

    #Send a "SYMBOLS" request to the spamd server.  Takes the message as a parameter, and returns
    #an SaResult object, with spam, score, threshold, and tags attributes set
    def symbols(message)
      lines = send_message("SYMBOLS", message)

      result = SaResult.new()

      if lines[0].chop =~ /(.+)\/(.+) (.+) (.+)/
        result.response_version = $2
        result.response_code = $3
        result.response_message = $4
      end

      if lines[1].chop =~ /^Spam: (.+) ; (.+) . (.+)$/
        result.score = $2
        result.spam = $1
        result.threshold = $3
      end

      if lines[3].chop =~ /(.*)/
        result.tags = $1.split(',')
      end

      return result
    end

    #send a "CHECK" request to the spamd server. Takes the message as a parameter, and returns
    #an SaResult object, with spam, score, and threshold, attributes set
    def check(message)
      lines = send_message("CHECK", message)

      result = SaResult.new()

      if lines[0].chop =~ /(.+)\/(.+) (.+) (.+)/
        result.response_version = $2
        result.response_code = $3
        result.response_message = $4
      end

      if lines[1].chop =~ /^Spam: (.+) ; (.+) . (.+)$/
        result.score = $2
        result.spam = $1
        result.threshold = $3
      end

      return result

    end


    #send a "REPORT" request to the spamd server. Takes the message as a parameter, and returns
    #an SaResult object, with spam, score, threshold, and report attributes set
    def report(message)
      lines = send_message("REPORT", message)

      result = SaResult.new()

      if lines[0].chop =~ /(.+)\/(.+) (.+) (.+)/
        result.response_version = $2
        result.response_code = $3
        result.response_message = $4
      end

      if lines[1].chop =~ /^Spam: (.+) ; (.+) . (.+)$/
        result.score = $2
        result.spam = $1
        result.threshold = $3
      end

      result.report = lines[3..-1].join()

      return result


    end

    #send a "REPORT" request to the spamd server. Takes the message as a parameter, and returns
    #an SaResult object, with spam, score, threshold, and report attributes set if the message is spam
    #otherwise, spam, score, and threshold are set. (spam set to "False")
    def report_ifspam(message)
      lines = send_message("REPORT_IFSPAM", message)

      result = SaResult.new()

      if lines[0].chop =~ /(.+)\/(.+) (.+) (.+)/
        result.response_version = $2
        result.response_code = $3
        result.response_message = $4
      end

      if lines[1].chop =~ /^Spam: (.+) ; (.+) . (.+)$/
        result.score = $2
        result.spam = $1
        result.threshold = $3
      end

      result.report = lines[3..-1].join() if result.spam == "Yes"

      return result
    end

    #skips the check and closes the connection, in case you don't really
    #need to scan now.
    def skip()
      lines = send_message("SKIP", message)
    end


    #sends a PING to the spamd server, should return with PONG in the
    #result.response_message
    def ping()
      result = SaResult.new()

      if lines[0].chop =~ /(.+)\/(.+) (.+) (.+)/
        result.response_version = $2
        result.response_code = $3
        result.response_message = $4
      end

      return result

    end

    #sends a PROCESS request to the spamd server, returns a processed message
    #in result.report.
    def process(message)
      lines = send_message("PROCESS", message)

      result = SaResult.new()


      if lines[0].chop =~ /(.+)\/(.+) (.+) (.+)/
        result.response_version = $2
        result.response_code = $3
        result.response_message = $4
      end

      if lines[1].chop =~ /Content-length: (.+)/
        result.content_length = $1
      end

      result.report = lines[3..-1].join()

      return result
    end

    # Let the server know that the message is spam.
    def is_spam(message)
      tell(message, 'spam')
    end

    # Let the server know that the message is not spam.
    def is_ham(message)
      tell(message, 'ham')
    end

    private

    # Sends a TELL request to the spamd server, communicating that the
    # message is either 'ham', 'spam', or 'forget' if we wish to make
    # the server forget the message.
    def tell(message, msgtype)
      lines = send_message("TELL", message, 'Message-class' => msgtype)
    end

    #helper function to send the necessary PROTOCOL codes to the server.
    #returns the reponse as an array of lines.
    def send_message(command, message, headers = {})
      connect
      len = message.length
      @s.write(command + " SPAMC/1.2\r\n")
      headers.each do |k,v|
        @s.write("#{k}: #{v}\r\n")
      end
      @s.write("Content-length: " + len.to_s + "\r\n\r\n")
      @s.write(message)
      @s.shutdown(1)  #have to shutdown sending side to get response
      lines = @s.readlines
      @s.close #might as well close it now
      @s = nil

      return lines

end


  end



  #A class that holds the return values from SpamC.
  #
  # :response_version Protocol version returned by server
  # :response_code    Response code return by server
  # :response_message Response code message returned by server
  #
  # :spam             Server's evaluation of whether the message was spam
  # :score            The actual score given to the message
  # :threshold        The threshold at which the server calls an item spam
  # :tags             List of tags that the message triggered.
  # :report           The report message returned by the server
  # :content_length   The length of the report returned by the server
  #
  #Note that not all attributes are returned by all methods.
  class SaResult  #consider using builtin Struct class instead?
    attr_accessor :response_version, :response_code, :response_message, :spam, :score, :threshold, :tags, :report, :content_length

    #simple output of all the data in the result. Useful for debugging purposes.
    def to_s
      result = "Response header: " + @response_version.to_s + " "+ @response_code.to_s + " "+ @response_message.to_s + "\n"
      result += "Content-length: " + @content_length + "\n" if ! @content_length.nil?
      result += "Spam: "+ @spam.to_s + "\n"+ @score.to_s + "/"+ @threshold.to_s + "\n" if ! @spam.nil?
      result += @tags.join("\n") if ! @tags.nil?
      result += @report.to_s if ! @report.nil?
    end

    #returns true if the message was spam, otherwise false
    def spam?
      if @spam == "True" || @spam == "Yes"
        return true;
      else
        return false
      end
    end

  end

end
