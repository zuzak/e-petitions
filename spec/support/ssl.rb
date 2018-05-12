RSpec.configure do |config|
  config.before(:each, type: :controller) do |example|
    if example.metadata[:admin]
      request.env['HTTP_HOST'] = Site.moderate_host_with_port
    else
      request.env['HTTP_HOST'] = Site.host_with_port
    end

    request.env['HTTPS'] = 'on'
  end

  config.before(:each, type: :request) do |example|
    if example.metadata[:admin]
      host! Site.moderate_host_with_port
    else
      host! Site.host_with_port
    end

    https!
  end
end
