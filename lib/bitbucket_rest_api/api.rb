# -*- encoding: utf-8 -*-

require 'bitbucket_rest_api/configuration'
require 'bitbucket_rest_api/core_ext/hash'
require 'bitbucket_rest_api/core_ext/array'
require 'bitbucket_rest_api/compatibility'
require 'bitbucket_rest_api/null_encoder'

require 'bitbucket_rest_api/request/verbs'

require 'bitbucket_rest_api/api/actions'
require 'bitbucket_rest_api/api/factory'
require 'bitbucket_rest_api/api/arguments'

module BitBucket
  class API
    extend BitBucket::ClassMethods
    include Constants
    include Authorization
    include Request::Verbs

    # TODO consider these optional in a stack
    include Validations
    include ParameterFilter
    include Normalizer

    @version = '1.0'

    attr_reader *BitBucket.configuration.property_names

    attr_accessor *Validations::VALID_API_KEYS

    attr_accessor :current_options

    # Callback to update global configuration options
    class_eval do
      BitBucket.configuration.property_names.each do |key|
        define_method "#{key}=" do |arg|
          self.instance_variable_set("@#{key}", arg)
          self.current_options.merge!({:"#{key}" => arg})
        end
      end
    end

    # Creates new API
    def initialize(options={}, &block)
      super()
      setup(options)
      yield_or_eval(&block) if block_given?
    end

    def yield_or_eval(&block)
      return unless block
      block.arity > 0 ? yield(self) : self.instance_eval(&block)
    end

    def setup(options={})
      options = BitBucket.configuration.fetch.merge(options)
      self.current_options = options
      if self.class.instance_variable_get('@version') == '2.0'
        options[:endpoint] = BitBucket.endpoint.gsub(/\/api\/[0-9.]+/, "/api/2.0")
      end
      BitBucket.configuration.property_names.each do |key|
        send("#{key}=", options[key])
      end
      process_basic_auth(options[:basic_auth])
    end

    # Extract login and password from basic_auth parameter
    def process_basic_auth(auth)
      case auth
      when String
        self.login, self.password = auth.split(':', 2)
      when Hash
        self.login    = auth[:login]
        self.password = auth[:password]
      end
    end

    # Assigns current api class
    def set_api_client
      BitBucket.api_client = self
    end

    # Responds to attribute query or attribute clear
    def method_missing(method, *args, &block) # :nodoc:
      case method.to_s
      when /^(.*)\?$/
        return !self.send($1.to_s).nil?
      when /^clear_(.*)$/
        self.send("#{$1.to_s}=", nil)
      else
        super
      end
    end

     # Acts as setter and getter for api requests arguments parsing.
    #
    # Returns Arguments instance.
    #
    def arguments(args=(not_set = true), options={}, &block)
      if not_set
        @arguments
      else
        @arguments = Arguments.new(options.merge!(api: self)).parse(*args, &block)
      end
    end

    # Scope for passing request required arguments.
    #
    def with(args)
      case args
      when Hash
        set args
      when /.*\/.*/i
        user, repo = args.split('/')
        set :user => user, :repo => repo
      else
        ::Kernel.raise ArgumentError, 'This api does not support passed in arguments'
      end
    end

    # Set a configuration option for a given namespace
    #
    # @param [String] option
    # @param [Object] value
    # @param [Boolean] ignore_setter
    #
    # @return [self]
    #
    # @api public
    def set(option, value=(not_set=true), ignore_setter=false, &block)
      raise ArgumentError, 'value not set' if block and !not_set
      return self if !not_set and value.nil?

      if not_set
        set_options option
        return self
      end

      if respond_to?("#{option}=") and not ignore_setter
        return __send__("#{option}=", value)
      end

      define_accessors option, value
      self
    end

    # Defines a namespace
    #
    # @param [Array[Symbol]] names
    #   the name for the scope
    #
    # @return [self]
    #
    # @api public
    def self.namespace(*names)
      options = names.last.is_a?(Hash) ? names.pop : {}
      names   = names.map(&:to_sym)
      name    = names.pop
      return if public_method_defined?(name)

      class_name = extract_class_name(name, options)
      define_method(name) do |*args, &block|
        options = args.last.is_a?(Hash) ? args.pop : {}
        API::Factory.new(class_name, current_options.merge(options), &block)
      end
      self
    end

    # Extracts class name from options
    #
    # @param [Hash] options
    # @option options [String] :full_name
    #   the full name for the class
    # @option options [Boolean] :root
    #   if the class is at the root or not
    #
    # @return [String]
    #
    # @api private
    def self.extract_class_name(name, options)
      converted  = options.fetch(:full_name, name).to_s
      converted  = converted.split('_').map(&:capitalize).join
      class_name = options.fetch(:root, false) ? '': "#{self.name}::"
      class_name += converted
      class_name
    end

    def _update_user_repo_params(user_name, repo_name=nil) # :nodoc:
      self.user = user_name || self.user
      self.repo = repo_name || self.repo
    end

    def _merge_user_into_params!(params)  #  :nodoc:
      params.merge!({ 'user' => self.user }) if user?
    end

    def _merge_user_repo_into_params!(params)   #  :nodoc:
      { 'user' => self.user, 'repo' => self.repo }.merge!(params)
    end


    private

    # Set multiple options
    #
    # @api private
    def set_options(options)
      unless options.respond_to?(:each)
        raise ArgumentError, 'cannot iterate over value'
      end
      options.each { |key, value| set(key, value) }
    end

    # Define setters and getters
    #
    # @api private
    def define_accessors(option, value)
      setter = proc { |val|  set option, val, true }
      getter = proc { value }

      define_singleton_method("#{option}=", setter) if setter
      define_singleton_method(option, getter) if getter
    end

    # Dynamically define a method for setting request option
    #
    # @api private
    def define_singleton_method(method_name, content=Proc.new)
      (class << self; self; end).class_eval do
        undef_method(method_name) if method_defined?(method_name)
        if String === content
          class_eval("def #{method_name}() #{content}; end")
        else
          define_method(method_name, &content)
        end
      end
    end

  end # API
end # BitBucket
