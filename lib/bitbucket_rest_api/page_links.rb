module BitBucket
  # Determines the links in the current response link header to be used
  # to find the links to other pages of request responses. These will
  # only be present if the result set size exceeds the per page limit.
  class PageLinks
    include BitBucket::Constants

    FIRST_PAGE_NUMBER = 1 # :nodoc:

    # Hold the extracted values for URI from the response body
    # for the next and previous page.
    attr_accessor :first, :next, :prev

    # Parses links from executed request
    #
    def initialize(response_body)
puts "RESPONSE BODY: #{response_body.inspect}"
      self.first = FIRST_PAGE_NUMBER
      self.next  = response_body[META_NEXT]
      self.prev  = response_body[META_PREV]
    end

  end # PageLinks
end # BitBucket
