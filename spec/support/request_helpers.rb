RSpec.configure do |config|
  helpers = Module.new do
    def json
      @json ||= JSON.parse(response.body)
    end
  end

  config.include helpers, type: :request
end
