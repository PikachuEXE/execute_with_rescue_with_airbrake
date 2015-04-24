require "active_support/core_ext/hash/indifferent_access"

module ExecuteWithRescueWithAirbrake
  module Adapters
    class AirbrakeAdapter
      module Errors
        InvalidParameters = Class.new(ArgumentError)
        ParameterKeyConflict = Class.new(ArgumentError)
      end

      # This should NOT be used directly, but used with rescue_from
      # if you need custom options use Airbrake directly
      #
      # @param ex [Exception]
      #   The exception rescued
      #
      # @raise [Exception] the original exception
      #   when Airbrake detects the current environment is not public
      # @see should_raise?
      def notify_or_raise(ex)
        if should_raise?
          fail ex
        else
          notify_or_ignore_with_options(ex)
        end
      end

      # set the default `error_class` option when notify by Airbrake
      # It must can be init without argument, this method won"t check it
      # Pass nil to clear it
      #
      # @param message [NilClass, Class]
      #   the error message to be used in Airbrake notice
      #
      # @raise [ArgumentError] when class is not nil or symbol
      def set_default_airbrake_notice_error_class(klass)
        (klass.nil? || klass.is_a?(Class)) || fail(ArgumentError)

        @default_airbrake_notice_error_class = klass
      end

      # set the default `error_message` option when notify by Airbrake
      # Pass nil to clear it
      #
      # @param message [NilClass, String]
      #   the error message to be used in Airbrake notice
      #
      # @raise [ArgumentError] when message is not nil or string
      def set_default_airbrake_notice_error_message(message)
        (message.nil? || message.is_a?(String)) || fail(ArgumentError)

        @default_airbrake_notice_error_message = message
      end

      # Push new default `parameters` option when notify by Airbrake
      # Pass nil to clear it
      #
      # @param new_params [Hash]
      #   the additional parameters to be used in Airbrake notice
      #
      # @raise [InvalidParameters]
      #   when new_params is not hash
      # @raise [ParameterKeyConflict]
      #   when new_params contains keys conflicting with existing keys
      def add_default_airbrake_notice_parameters(new_params)
        new_params.is_a?(Hash) || fail(Errors::InvalidParameters)
        new_params = new_params.with_indifferent_access

        # find out common element size (which should be 0)
        common_keys = default_airbrake_notice_parameters.keys & new_params.keys
        if common_keys.size > 0
          fail(
            Errors::ParameterKeyConflict,
            "Conflicting keys: #{common_keys.inspect}",
          )
        end

        default_airbrake_notice_parameters.merge!(new_params)
      end

      private

      def notify_or_ignore_with_options(ex)
        Airbrake.notify_or_ignore(ex, build_notice_options)
      end

      def build_notice_options
        h = {}

        @default_airbrake_notice_error_class &&
          h[:error_class] = @default_airbrake_notice_error_class
        @default_airbrake_notice_error_message &&
          h[:error_message] = @default_airbrake_notice_error_message
        !default_airbrake_notice_parameters.empty? &&
          h[:parameters] = default_airbrake_notice_parameters.symbolize_keys

        h
      end

      def default_airbrake_notice_parameters
        @default_airbrake_notice_parameters ||= HashWithIndifferentAccess.new
      end

      # @return [Boolean]
      #   Whether the adapter should raise the error instead
      #   (like in development or test)
      #
      # @see Airbrake.configuration.development_environments
      def should_raise?
        !Airbrake.configuration.public?
      end
    end
  end
end
