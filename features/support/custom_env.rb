require 'email_spec/cucumber'
require 'rspec/core/pending'
require 'capybara/poltergeist'
require 'webrick/httpproxy'

Capybara.javascript_driver = :poltergeist
Capybara.default_max_wait_time = 5
Capybara.server_port = 3443
Capybara.app_host = "https://test.epetitions.website:3443"
Capybara.default_host = "https://test.epetitions.website:3443"
Capybara.default_selector = :xpath
Capybara.automatic_label_click = true

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
    phantomjs_logger: "/dev/null",
    phantomjs_options: [
      '--ignore-ssl-errors=yes',
      '--local-to-remote-url-access=yes'
    ]
  )
end

Capybara.register_server :epets do |app, port|
  Epets::SSLServer.build(app, port)
end

Capybara.server = :epets

module CucumberI18n
  def t(*args)
    I18n.t(*args)
  end
end

module CucumberSanitizer
  def strip_tags(html)
    @sanitizer ||= Rails::Html::FullSanitizer.new
    @sanitizer.sanitize(html, encode_special_chars: false)
  end
end

World(CucumberI18n)
World(CucumberSanitizer)
World(RejectionHelper)

# run background jobs inline with delayed job
ActiveJob::Base.queue_adapter = :delayed_job
Delayed::Worker.delay_jobs = false
