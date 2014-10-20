module BitBucket
  # Determines the links in the current response link header to be used
  # to find the links to other pages of request responses. These will
  # only be present if the result set size exceeds the per page limit.
  class PageLinks
    include BitBucket::Constants

    FIRST_PAGE_NUMBER = 1 # :nodoc:

    # Hold the extracted values for URI from the response body
    # for the next and previous page.
    attr_accessor :response_env, :first, :next, :prev

    # Parses links from executed request
    #
    def initialize(response)
      self.response_env = response
      self.first        = path_for_page(FIRST_PAGE_NUMBER)
      self.next         = response.body[META_NEXT]
      self.prev         = response.body[META_PREV]
    end

    private

    def path_for_page(page_number)
      self.response_env.url.to_s.gsub(BitBucket.endpoint, '')
    end

  end # PageLinks
end # BitBucket
