# encoding: utf-8

require 'bitbucket_rest_api/utils/url'
require 'uri'

module BitBucket
  class PageIterator
    include BitBucket::Constants
    include BitBucket::Utils::Url
    include BitBucket::PagedRequest

    # Setup attribute accesor for all the link types
    ATTRIBUTES = [ META_FIRST, META_NEXT, META_PREV ]

    ATTRIBUTES.each do |attr|
      attr_accessor :"#{attr}_page_uri", :"#{attr}_page"
    end

    attr_reader :current_api

    def initialize(links, current_api)
      @links        = links
      @current_api = current_api
      update_page_links @links
    end

    def has_next?
      next_page == 0 || !next_page_uri.nil?
    end

    # Perform http get request for the first resource
    #
    def first
      return nil unless first_page_uri
      perform_request(first_page_uri)
    end

    # Perform http get request for the next resource
    #
    def next
      return nil unless has_next?
      perform_request(next_page_uri)
    end

    # Perform http get request for the previous resource
    #
    def prev
      return nil unless prev_page_uri
      perform_request(prev_page_uri)
    end

    # Returns the result for a specific page.
    #
    def get_page(page_number)
      # Find URI that we can work with, if we cannot get the first
      # page URI then there is only one page.
      return nil unless first_page_uri
      params = parse_query URI(first_page_uri).query
      params['page']     = page_number

      response = page_request URI(first_page_uri).path, params
      update_page_links response.links
      response
    end

  private

    def perform_request(attribute)
      page_uri = URI(attribute)
      params = parse_query(page_uri.query)

      if next_page and next_page >= 1
        params['page'] = attribute.to_i
      end

      response = page_request(page_uri.path, params)
      update_page_links response.links
      response
    end

    # Wholesale update of all link attributes
    def update_page_links(links) # :nodoc:
      ATTRIBUTES.each do |attr|
        self.send(:"#{attr}_page_uri=", links.send(:"#{attr}"))
        self.send(:"#{attr}_page=", links.send(:"#{attr}"))
      end
    end

  end # PageIterator
end # BitBucket
