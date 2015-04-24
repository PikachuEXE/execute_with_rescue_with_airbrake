require "airbrake"
require "active_support/concern"
require "active_support/core_ext/module/delegation"

require "execute_with_rescue"
require "execute_with_rescue/errors/no_airbrake_adapter"
require "execute_with_rescue_with_airbrake/adapters/airbrake_adapter"

module ExecuteWithRescue
  module Mixins
    module WithAirbrake
      extend ActiveSupport::Concern

      included do
        include ExecuteWithRescue::Mixins::Core

        add_execute_with_rescue_before_hook do
          _execute_with_rescue_airbrake_adapters.
            push(ExecuteWithRescueWithAirbrake::Adapters::AirbrakeAdapter.new)
        end
        add_execute_with_rescue_after_hook do
          _execute_with_rescue_airbrake_adapters.pop
        end

        rescue_from(
          StandardError,
          with: :notify_by_airbrake_or_raise,
        )

        delegate(
          :set_default_airbrake_notice_error_class,
          :set_default_airbrake_notice_error_message,
          :add_default_airbrake_notice_parameters,
          to: :_execute_with_rescue_current_airbrake_adapter,
        )
      end

      # Call this if you have some custom handling for some classes
      # Override this if you have some additional operation like logging
      # for all kinds of error inherited from `StandardError`
      #
      # @example Add default parameters when rescuing AR Invalid Error
      #   class SomeWorker
      #     rescue_from ActiveRecord::RecordInvalid,
      #                 with: :notify_by_airbrake_or_raise_ar_invalid_error
      #
      #     def notify_by_airbrake_or_raise_ar_invalid_error(ex)
      #       add_default_airbrake_notice_parameters({
      #         active_record_instance: ex.record.inspect,
      #         active_record_instance_errors: ex.record.errors.inspect,
      #       })
      #       notify_by_airbrake_or_raise(ex)
      #     end
      #   end
      def notify_by_airbrake_or_raise(ex)
        _execute_with_rescue_current_airbrake_adapter.
          notify_or_raise(ex)
      end

      # For pushing and popping the adapters
      def _execute_with_rescue_airbrake_adapters
        @_execute_with_rescue_airbrake_adapters ||= []
      end

      def _execute_with_rescue_current_airbrake_adapter
        _execute_with_rescue_airbrake_adapters.last ||
          fail(ExecuteWithRescue::Errors::NoAirbrakeAdapter)
      end
    end
  end
end
