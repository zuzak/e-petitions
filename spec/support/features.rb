RSpec.configure do |config|
  helper = Module.new do
    def visit(url)
      if url =~ %r[^/admin]
        super("https://test-moderate.epetitions.website:3443#{url}")
      elsif url =~ %r[^/]
        super("https://test.epetitions.website:3443#{url}")
      else
        super
      end
    end
  end

  config.include(helper, type: :feature)
  config.include(FactoryBot::Syntax::Methods, type: :feature)
end
