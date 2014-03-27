# ExecuteWithRescueWithAirbrake

The Airbrake adapter plus mixin to be used with `execute_with_rescue`.

## Support
Tested against:
- Active Support of version `3.2`, `4.0` and `4.1` (pre-3.2 got wrong dependency & I don't want to support)
- MRI `1.9.3`, `2.0.0`, `2.1.0`, `2.1.1`

[![Build Status](http://img.shields.io/travis/PikachuEXE/execute_with_rescue_with_airbrake.svg)](https://travis-ci.org/PikachuEXE/execute_with_rescue_with_airbrake)
[![Gem Version](http://img.shields.io/gem/v/execute_with_rescue_with_airbrake.svg)](http://badge.fury.io/rb/execute_with_rescue_with_airbrake)
[![Dependency Status](http://img.shields.io/gemnasium/PikachuEXE/execute_with_rescue_with_airbrake.svg)](https://gemnasium.com/PikachuEXE/execute_with_rescue_with_airbrake)
[![Coverage Status](http://img.shields.io/coveralls/PikachuEXE/execute_with_rescue_with_airbrake.svg)](https://coveralls.io/r/PikachuEXE/execute_with_rescue_with_airbrake)
[![Code Climate](http://img.shields.io/codeclimate/github/PikachuEXE/execute_with_rescue_with_airbrake.svg)](https://codeclimate.com/github/PikachuEXE/execute_with_rescue_with_airbrake)

## Installation

Add this line to your application's Gemfile:

    gem 'execute_with_rescue_with_airbrake'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install execute_with_rescue_with_airbrake

## Usage

Note: You must configurate `airbrake` first or you won't be able to send anything (I have to do the same in `spec_helper`)

### `include ExecuteWithRescue::Mixins::WithAirbrake`
Once inlcuded, `rescue_from StandardError, with: :notify_by_airbrake_or_raise` will be called.


### `#set_default_airbrake_notice_error_class`, `#set_default_airbrake_notice_error_message`, `#add_default_airbrake_notice_parameters`
**Private** methods to be called within a block in `execute_with_rescue`  
Every `execute_with_rescue` call will push a new airbrake adapater for the instance (with before hook),  
so you can have different custom error class, message or/and parameters within the same service/worker class.  
You should call these methods within the block passed to `execute_with_rescue`, as there is no adapter from the beginning.

Here is an example for getting a document from the network:
```ruby
class SomeServiceClass

  BadNetworkConnectionError = Class.new(StandardError)

  include ExecuteWithRescue::Mixins::WithAirbrake

  # then run code with possible errors
  def perform(url_of_webpage)
    execute_with_rescue do
      set_default_airbrake_notice_error_class(BadNetworkConnectionError)
      set_default_airbrake_notice_error_message("We have a bad network today...")
      add_default_airbrake_notice_parameters({url_of_webpage: url_of_webpage})

      # Calling `add_default_airbrake_notice_parameters` with duplicated key(s) would raise error
      # add_default_airbrake_notice_parameters({url_of_webpage: something_else}) => 
      #   ExecuteWithRescueWithAirbrake::Adapters::AirbrakeAdapter::Errors::ParameterKeyConflict

      doc = Nokogiri::HTML(open(listing_url))
    end
  end
end
```

If you have a custom error that generates error message from the argument, (and you don't want to duplicate how it generates the message)  
You can do as the following:
```ruby
class SomeServiceClass
  class CustomErrorWithMessage < StandardError
    def self.new(thing)
      msg = "#{thing.class} has error"
      super(msg)
    end
  end

  def perform
    execute_with_rescue do
      do_something
    end
  end

  def do_something
    # If you cannot provide the argument for the exception at this point then I can't help you
    # You should really use `begin...rescue...end` for such customization
    set_default_airbrake_notice_error_class(CustomErrorWithMessage)
    set_default_airbrake_notice_error_message(CustomErrorWithMessage.new(:foo).message)

    raise StandardError
  end
end
```

### `#notify_by_airbrake_or_raise`
**Private** method to be called automatically by `rescue_from StandardError` from the mixin.  
Call this if you have some custom handling for some error classes  
Override this if you have some additional operation like logging for all kinds of error inherited from `StandardError`  
Note: It would re-raise the exception if `airbrake` would ignore all notify call in that environment (see `development_environments` in its config).  
Example:
```ruby
class SomeWorker
  rescue_from ActiveRecord::RecordInvalid,
              with: :notify_by_airbrake_or_raise_ar_invalid_error

  def notify_by_airbrake_or_raise_ar_invalid_error(ex)
    add_default_airbrake_notice_parameters({
      active_record_instance: ex.record.inspect,
      active_record_instance_errors: ex.record.errors.inspect,
    })
    notify_by_airbrake_or_raise(ex)
  end
end
```

## Contributing

1. Fork it ( http://github.com/PikachuEXE/execute_with_rescue_with_airbrake/fork )
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create new Pull Request
