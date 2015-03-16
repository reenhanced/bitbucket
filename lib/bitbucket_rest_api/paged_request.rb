# encoding: utf-8

module BitBucket

  # A module that adds http get request to response pagination
  module PagedRequest
    include BitBucket::Constants
    include BitBucket::Normalizer

    FIRST_PAGE = 1 # Default request page if none provided

    NOT_FOUND  = -1 # Page parameter not present

    def default_page
      current_api.current_page ? current_api.current_page : FIRST_PAGE
    end

    # Perform http get request with pagination parameters
    #
    def page_request(path, params={})
      if params[PARAM_PAGE] && params[PARAM_PAGE] == NOT_FOUND
        params[PARAM_PAGE] = default_page
      end

      current_api.get_request(path, ParamsHash.new(params))
    end

  end # PagedRequest
end # BitBucket
