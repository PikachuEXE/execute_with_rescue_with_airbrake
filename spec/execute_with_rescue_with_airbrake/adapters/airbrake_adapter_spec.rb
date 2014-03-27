require 'spec_helper'


describe ExecuteWithRescueWithAirbrake::Adapters::AirbrakeAdapter do
  let!(:instance) { described_class.new }

  let!(:notice_options) do
    {parameters: {}}
  end
  let!(:exception_rescued) { StandardError.new('hi I am test error') }

  let(:notify_or_raise) { instance.notify_or_raise(exception_rescued) }

  #before {  }

  context 'when exception should not be notified according to Airbrake' do
    before { Airbrake.configuration.stub(public?: false) }

    it 're-raise the rescue error' do
      expect { notify_or_raise }.to raise_error(exception_rescued.class,
                                                exception_rescued.message)
    end
  end
  context 'when exception should be notified according to Airbrake' do
    before { Airbrake.configuration.stub(public?: true) }

    it 'does not re-raise the rescued error' do
      expect { notify_or_raise }.to_not raise_error
    end
  end

  context 'assuming Airbrake says it error should be notified' do
    before { Airbrake.configuration.stub(public?: true) }

    it 'calls Airbrake.notify_or_ignore' do
      Airbrake.should_receive(:notify_or_ignore)

      notify_or_raise
    end


    describe '#set_default_airbrake_notice_error_class' do
      let(:set_error_class) do
        instance.set_default_airbrake_notice_error_class(
          default_error_class)
      end
      let(:default_error_class) { nil }
      let(:option_key) { :error_class }

      before do
        # Return the options only
        Airbrake.stub(:notify_or_ignore) {|*args| args.last }
      end
      let(:options_hash) { notify_or_raise }
      subject { options_hash }

      context 'when its not called' do
        its(:keys) { should_not include(option_key) }
      end
      context 'when its called with nil' do
        let(:default_error_class) { nil }
        before { set_error_class }

        its(:keys) { should_not include(option_key) }
      end
      context 'when its called with custom error' do
        let(:default_error_class) { ArgumentError }
        before { set_error_class }

        it { should include({option_key => default_error_class}) }
      end
    end

    describe '#set_default_airbrake_notice_error_message' do
      let(:set_error_message) do
        instance.set_default_airbrake_notice_error_message(
          default_error_message)
      end
      let(:default_error_message) { nil }
      let(:option_key) { :error_message }

      before do
        # Return the options only
        Airbrake.stub(:notify_or_ignore) {|*args| args.last }
      end
      let(:options_hash) { notify_or_raise }
      subject { options_hash }

      context 'when its not called' do
        its(:keys) { should_not include(option_key) }
      end
      context 'when its called with nil' do
        let(:default_error_message) { nil }
        before { set_error_message }

        its(:keys) { should_not include(option_key) }
      end
      context 'when its called with custom error' do
        let(:default_error_message) { 'hello' }
        before { set_error_message }

        it { should include({option_key => default_error_message}) }
      end
    end

    describe '#add_default_airbrake_notice_parameters' do
      # Must defined as method or it won't run twice
      def add_parameters(params = new_parameters)
        instance.add_default_airbrake_notice_parameters(
          params)
      end
      let(:new_parameters) { Hash.new }
      let(:option_key) { :parameters }

      before do
        # Return the options only
        Airbrake.stub(:notify_or_ignore) {|*args| args.last }
      end
      let(:options_hash) { notify_or_raise }
      let(:parameters_hash) { options_hash[option_key] }

      subject { options_hash }

      context 'when its not called' do
        its(:keys) { should_not include(option_key) }
      end
      context 'when its called with non hash' do
        let(:new_parameters) { Array.new }
        let(:expected_error_class) do
          described_class::Errors::InvalidParameters
        end

        specify do
          expect { add_parameters }
          .to raise_error(expected_error_class)
        end
      end
      context 'when its called with empty hash' do
        let(:new_parameters) { Hash.new }
        before { add_parameters }

        its(:keys) { should_not include(option_key) }
      end

      context 'when its called with non-empty hash' do
        subject { parameters_hash }

        let(:new_parameters) { {foo: :bar} }

        context 'and there is no conflicting key' do
          before { add_parameters }

          it { should include(new_parameters) }
        end

        context 'and there is a conflicting key' do
          before { add_parameters }
          let(:expected_error_class) do
            described_class::Errors::ParameterKeyConflict
          end

          context 'in symbol' do
            specify do
              expect { add_parameters }
              .to raise_error(expected_error_class)
            end
          end
          context 'in string' do
            specify do
              expect { add_parameters(new_parameters.stringify_keys) }
              .to raise_error(expected_error_class)
            end
          end
        end
      end
    end


    describe 'options passed' do
      context 'when nothing is set' do
        specify do
          expect(Airbrake)
          .to(receive(:notify_or_ignore)
              .with(kind_of(StandardError), {}))

          notify_or_raise
        end
      end
      context 'when all things are set' do
        let!(:custom_error_class) { Class.new(StandardError) }
        let!(:custom_error_message) { 'hi' }
        let!(:custom_parameters) { {foo: :bar}.stringify_keys }
        before { instance.set_default_airbrake_notice_error_class(custom_error_class) }
        before { instance.set_default_airbrake_notice_error_message(custom_error_message) }
        before { instance.add_default_airbrake_notice_parameters(custom_parameters) }

        specify do
          expect(Airbrake)
          .to(receive(:notify_or_ignore)
              .with(kind_of(StandardError), {
            error_class: custom_error_class,
            error_message: custom_error_message,
            parameters: custom_parameters.symbolize_keys,
          }))

          notify_or_raise
        end
      end
    end
  end
end
