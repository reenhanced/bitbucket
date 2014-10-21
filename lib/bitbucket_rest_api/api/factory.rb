# encoding: utf-8

require 'bitbucket_rest_api/core_ext/hash'

module BitBucket
  class API
    class Factory

      # Instantiates a new bitbucket api object
      def self.new(klass, options={}, &block)
        return create_instance(klass, options, &block) if klass
        raise ArgumentError, 'must provide klass to be instantiated'
      end

      # Passes configuration options to instantiated class
      def self.create_instance(klass, options, &block)
        options.symbolize_keys!
        convert_to_constant(klass.to_s).new options, &block
      end

      def self.convert_to_constant(classes)
        classes.split('::').inject(BitBucket) do |constant, klass|
          constant.const_get klass
        end
      end

    end # Factory
  end # Api
end # BitBucket
