module BitBucket
  # Determines the links in the current response to be used
  # to find the links to other pages of request responses.
  class PageLinks
    include BitBucket::Constants

    FIRST_PAGE_NUMBER = 1 # :nodoc:

    # Hold the extracted values for URI from the response body
    # for the next and previous page.
    attr_accessor :response_dup, :first, :next, :prev

    # Parses links from executed request
    #
    def initialize(response)
      self.response_dup = response
      if response.body.is_a?(Hash) and !response.body[PARAM_PAGE].nil?
        self.first        = path_for_page(FIRST_PAGE_NUMBER)
        self.next         = response.body[META_NEXT] unless response.body
        self.prev         = response.body[META_PREV]
      end
    end

    private

    def path_for_page(page_number)
      if response_dup.respond_to?(:url)
        self.response_dup.url.to_s.gsub(BitBucket.endpoint, '')
      end
    end

  end # PageLinks
end # BitBucket
