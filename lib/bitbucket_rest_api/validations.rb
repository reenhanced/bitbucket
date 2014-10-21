# encoding: utf-8

module BitBucket
  module Validations

    BitBucket::require_all 'bitbucket_rest_api/validations',
      'presence',
      'token',
      'format',
      'required'

    include Presence
    include Format
    include Token
    include Required

    VALID_API_KEYS = [
        'page',
        'per_page',
        'auto_pagination',
        'jsonp_callback'
    ]

  end # Validation
end # BitBucket
