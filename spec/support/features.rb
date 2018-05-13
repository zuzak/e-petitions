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

RSpec::Matchers.define :have_search_result do |columns, index|
  match do |actual|
    page.within(:search_result, index) do
      columns.each do |column|
        expect(page).to have_content(column)
      end
    end
  end
end

RSpec::Matchers.define :have_search_results do |results|
  match do |actual|
    results = \
      results.strip.split("\n").map do |line|
        line.strip.scan(/[^|]+/).map(&:strip)
      end

    page.within(:search_results) do
      children = page.find_all(:xpath, "./li")
      expect(children.size).to eq(results.size)

      results.each_with_index do |result, index|
        expect(page).to have_search_result(result, index + 1)
      end
    end
  end

  failure_message do
    "did not match the search results"
  end
end
