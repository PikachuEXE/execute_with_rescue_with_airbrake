
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
    raise StandardError
  end
end
class TestServiceWithAirbrakeWithErrorAndAirbrakeOption <
    TestServiceWithAirbrakeWithError

  CustomError = Class.new(StandardError)

  def do_something
    set_default_airbrake_notice_error_class(CustomError)
    set_default_airbrake_notice_error_message('hi')
    add_default_airbrake_notice_parameters({foo: :bar})

    super
  end
end

class TestServiceWithAirbrakeWithExecuteWithRescueCall <
    TestServiceWithAirbrake

  def do_something
    set_default_airbrake_notice_error_message('test')
  end
end
class TestServiceWithAirbrakeWithoutExecuteWithRescueCall <
    TestServiceWithAirbrakeWithExecuteWithRescueCall

  def call
    # without `execute_with_rescue`
    do_something
  end
end
