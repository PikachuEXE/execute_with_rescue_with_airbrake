
class TestServiceWithAirbrake
  include ExecuteWithRescue::Mixins::WithAirbrake

  def call
    execute_with_rescue do
      do_something
    end
  end

  private

  def do_something
    # do nothing
  end
end

class TestServiceWithAirbrakeWithError < TestServiceWithAirbrake
  def do_something
    fail StandardError
  end
end
class TestServiceWithAirbrakeWithErrorAndAirbrakeOption <
    TestServiceWithAirbrakeWithError

  CustomError = Class.new(StandardError)

  def do_something
    set_default_airbrake_notice_error_class(CustomError)
    set_default_airbrake_notice_error_message("hi")
    add_default_airbrake_notice_parameters(foo: :bar)

    super
  end
end
class TestServiceWithAirbrakeWithCustomErrorAndMessage <
    TestServiceWithAirbrakeWithErrorAndAirbrakeOption

  class CustomErrorWithMessage < StandardError
    def self.new(thing)
      msg = "#{thing.class} has error"
      super(msg)
    end
  end

  def do_something
    set_default_airbrake_notice_error_class(CustomErrorWithMessage)
    set_default_airbrake_notice_error_message(CustomErrorWithMessage.new(:foo).message)

    fail StandardError
  end
end

class TestServiceWithAirbrakeWithExecuteWithRescueCall <
    TestServiceWithAirbrake

  def do_something
    set_default_airbrake_notice_error_message("test")
  end
end
class TestServiceWithAirbrakeWithoutExecuteWithRescueCall <
    TestServiceWithAirbrakeWithExecuteWithRescueCall

  def call
    # without `execute_with_rescue`
    do_something
  end
end
