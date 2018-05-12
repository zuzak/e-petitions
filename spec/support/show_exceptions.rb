RSpec.configure do |config|
  helper = Module.new do
    def with_show_exceptions(on_or_off, &block)
      begin
        env_config = Rails.application.env_config
        show_exceptions = env_config['action_dispatch.show_exceptions']
        show_detailed_exceptions = env_config['action_dispatch.show_detailed_exceptions']
        env_config['action_dispatch.show_exceptions'] = on_or_off
        env_config['action_dispatch.show_detailed_exceptions'] = !on_or_off

        yield
      ensure
        env_config['action_dispatch.show_exceptions'] = show_exceptions
        env_config['action_dispatch.show_detailed_exceptions'] = show_detailed_exceptions
      end
    end
  end

  config.include(helper, type: :request)

  config.around(:each, type: :request) do |example|
    if example.metadata.key?(:show_exceptions)
      with_show_exceptions(example.metadata[:show_exceptions]) do
        example.run
      end
    else
      example.run
    end
  end
end
