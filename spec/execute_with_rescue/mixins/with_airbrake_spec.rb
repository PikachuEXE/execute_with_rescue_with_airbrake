require 'spec_helper'


describe ExecuteWithRescue::Mixins::WithAirbrake do
  let(:test_class) { TestServiceWithAirbrake }
  let(:test_class_instance) { test_class.new }
  let(:call_service) { test_class_instance.call }

  let(:adapter_class) do
    ExecuteWithRescueWithAirbrake::Adapters::AirbrakeAdapter
  end
  let!(:adapter_instance) { adapter_class.new }
  before do
    # Avoid Error
    test_class_instance
    .stub(:_execute_with_rescue_current_airbrake_adapter)
    .and_return(adapter_instance)
  end

  describe 'included modules' do
    subject { test_class.ancestors }

    it {should include ExecuteWithRescue::Mixins::Core}
    it {should include ExecuteWithRescue::Mixins::WithAirbrake}
  end

  describe 'delegation' do
    let(:adapter_class) do
      ExecuteWithRescueWithAirbrake::Adapters::AirbrakeAdapter
    end

    before { adapter_instance.stub(method_name) }

    let(:send_message) { test_class_instance.send(method_name) }

    shared_examples_for 'delegation' do
      specify do
        expect(adapter_instance).to receive(method_name)

        send_message
      end
    end

    describe 'for #set_default_airbrake_notice_error_class' do
      let(:method_name) { :set_default_airbrake_notice_error_class }

      it_behaves_like 'delegation'
    end
    describe 'for #set_default_airbrake_notice_error_message' do
      let(:method_name) { :set_default_airbrake_notice_error_message }

      it_behaves_like 'delegation'
    end
    describe 'for #add_default_airbrake_notice_parameters' do
      let(:method_name) { :add_default_airbrake_notice_parameters }

      it_behaves_like 'delegation'
    end
  end

  describe 'execution' do
    before { Airbrake.configuration.stub(public?: true) }

    describe 'when there is no error raised' do
      specify do
        expect(Airbrake)
        .to_not receive(:notify_or_ignore)

        call_service
      end
    end
    describe 'when there is error raised' do
      context 'and it is a standard error' do
        let(:test_class) { TestServiceWithAirbrakeWithError }

        specify do
          expect(Airbrake)
          .to(receive(:notify_or_ignore)
              .with(kind_of(StandardError), {}))

          call_service
        end
      end

      describe 'setting custom airbrake options' do
        let(:test_class) { TestServiceWithAirbrakeWithErrorAndAirbrakeOption }

        specify do
          expect(Airbrake)
          .to(receive(:notify_or_ignore)
              .with(kind_of(StandardError), {
            error_class: test_class::CustomError,
            error_message: 'hi',
            parameters: {
              foo: :bar
            },
          }))

          call_service
        end
      end
    end
  end
end
