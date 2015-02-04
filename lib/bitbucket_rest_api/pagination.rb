# encoding: utf-8

module BitBucket

  # A module that decorates response with pagination helpers
  module Pagination
    include BitBucket::Constants

    def paginated?
      body.is_a?(Hash) and body[PARAM_PAGE].nil?
    end

    # Return page links
    def links
      @links = BitBucket::PageLinks.new(self.response)
    end

    # Iterate over results set pages by automatically calling `next_page`
    # until all pages are exhausted. Caution needs to be exercised when
    # using this feature - 100 pages iteration will perform 100 API calls.
    # By default this is off. You can set it on the client, individual API
    # instances or just per given request.
    #
    def auto_paginate(auto=false)
      if (current_api.auto_pagination? || auto)
        resources_bodies = []
        each_page do |resource|
          if resource.body.respond_to?(:values)
            resources_bodies += resource.body[:values].collect {|value| ::Hashie::Mash.new(value) }
          else
            resources_bodies += Array(resource.body)
          end
        end
        self.body = resources_bodies
      end
      self
    end

    # Iterator like each for response pages. If there are no pages to
    # iterate over this method will return current page.
    def each_page
      yield self
      while page_iterator.has_next?
        yield next_page
      end
    end

    # Retrives the result of the first page. Returns <tt>nil</tt> if there is
    # no first page - either because you are already on the first page
    # or there are no pages at all in the result.
    def first_page
      first_request = page_iterator.first
      self.instance_eval { @env = first_request.env } if first_request
      first_request
    end

    # Retrives the result of the next page. Returns <tt>nil</tt> if there is
    # no next page or no pages at all.
    def next_page
      next_request = page_iterator.next
      self.instance_eval { @env = next_request.env } if next_request
      next_request
    end

    # Retrives the result of the previous page. Returns <tt>nil</tt> if there is
    # no previous page or no pages at all.
    def prev_page
      prev_request = page_iterator.prev
      self.instance_eval { @env = prev_request.env } if prev_request
      prev_request
    end
    alias :previous_page :prev_page

    # Retrives a specific result for a page given page number.
    # The <tt>page_number</tt> parameter is not validate, hitting a page
    # that does not exist will return BitBucket API error. Consequently, if
    # there is only one page, this method returns nil
    def page(page_number)
      request = page_iterator.get_page(page_number)
      self.instance_eval { @env = request.env } if request
      request
    end

    # Returns <tt>true</tt> if there is another page in the result set,
    # otherwise <tt>false</tt>
    def has_next_page?
      page_iterator.has_next?
    end

    private

    # Internally used page iterator
    def page_iterator # :nodoc:
      @page_iterator = BitBucket::PageIterator.new(links, current_api)
    end

  end # Pagination
end # BitBucket
