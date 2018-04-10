RSpec.configure do |config|
  config.include(ActiveJob::TestHelper)

  callbacks = Module.new do
    extend ActiveSupport::Concern

    included do
      around do |example|
        perform_enqueued_jobs { example.run }
      end
    end
  end

  config.include(callbacks, type: :feature)
end
