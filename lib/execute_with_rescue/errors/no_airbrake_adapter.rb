module ExecuteWithRescue
  module Errors
    class NoAirbrakeAdapter < RuntimeError
      def self.new(msg = nil)
        msg ||= <<-ERR_MSG
          There is no airbrake adapter available.
          Maybe you forgot to use `execute_with_rescue`?
        ERR_MSG
        super(msg)
      end
    end
  end
end
