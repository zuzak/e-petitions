require "chromedriver/helper"
require "selenium/webdriver"

Chromedriver.set_version("2.38")

Capybara.app_host = "https://test.epetitions.website:3443"
Capybara.default_host = "https://test.epetitions.website:3443"

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    acceptSslCerts: true,
    acceptInsecureCerts: true,
    chromeOptions: { args: %w[
      headless disable-gpu ignore-certificate-errors no-sandbox
    ] }
  )

  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

Capybara.register_server :epets do |app, port|
  Epets::SSLServer.build(app, port)
end

Capybara.server = :epets
Capybara.server_port = 3443

Capybara.javascript_driver = ENV.fetch("JS_DRIVER", "headless_chrome").to_sym

Capybara.automatic_label_click = true
Capybara.default_selector = :xpath
Capybara.default_max_wait_time = 5

Capybara.add_selector(:form_group) do
  xpath { |index| "//form/div[contains(@class, 'form-group')][#{index}]" }
end

Capybara.add_selector(:noindex) do
  xpath { "//meta[@name='robots' and @content='noindex']" }
end
