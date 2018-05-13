require "rails_helper"

RSpec.feature "Arnold searches from the home page", js: true do

  # In order to reduce the likelihood of a duplicate petition being made
  # As a petition moderator
  # I want to prominently show a petition search for the current parliament from the home page

  background do
    create_petitions
    create_archived_petitions
  end

  scenario "Arnold searches for petitions when parliament is open" do
    visit_home_page
    search_petitions "Wombles"

    expect_search_results_to_be "Wombles", 6, <<-STR
      | Wombles                            | 1 signature             |
      | Overthrow the Wombles              | 1 signature             |
      | Uncle Bulgaria                     | 1 signature             |
      | Common People                      | 1 signature             |
      | The Wombles will rock Glasto       | 1 signature, now closed |
      | Eavis vs the Wombles               | Rejected                |
    STR
  end

  scenario "Arnold searches for petitions when parliament is dissolving" do
    given_parliament_is_dissolving

    visit_home_page
    search_petitions "Wombles"

    expect_search_results_to_be "Wombles", 6, <<-STR
      | Wombles                            | 1 signature             |
      | Overthrow the Wombles              | 1 signature             |
      | Uncle Bulgaria                     | 1 signature             |
      | Common People                      | 1 signature             |
      | The Wombles will rock Glasto       | 1 signature, now closed |
      | Eavis vs the Wombles               | Rejected                |
    STR
  end

  scenario "Arnold searches for petitions when parliament has dissolved" do
    given_parliament_has_dissolved

    visit_home_page
    search_petitions "Wombles"

    expect_search_results_to_be "Wombles", 6, <<-STR
      | Wombles                            | 1 signature             |
      | Overthrow the Wombles              | 1 signature             |
      | Uncle Bulgaria                     | 1 signature             |
      | Common People                      | 1 signature             |
      | The Wombles will rock Glasto       | 1 signature, now closed |
      | Eavis vs the Wombles               | Rejected                |
    STR
  end

  scenario "Arnold searches for petitions when parliament is pending" do
    given_parliament_is_pending

    visit_home_page
    search_petitions "Rivers"

    expect_archive_search_results_to_be "Rivers", 3, <<-STR
      | Rivers are great         | 835 signatures |
      | Cry me a river           | 639 signatures |
      | More rivers please       | 243 signatures |
    STR
  end

  # #mark step definitions

  def create_petitions
    create :pending_petition, action: "Wombles are great", created_at: 1.minute.ago
    create :validated_petition, action: "The Wombles of Wimbledon", created_at: 2.hours.ago
    create :open_petition, action: "Uncle Bulgaria", additional_details: "The Wombles are here", created_at: 3.days.ago
    create :open_petition, action: "Common People", background: "The Wombles belong to us all", created_at: 4.days.ago
    create :open_petition, action: "Overthrow the Wombles", created_at: 2.days.ago
    create :closed_petition, action: "The Wombles will rock Glasto", created_at: 5.days.ago
    create :rejected_petition, action: "Eavis vs the Wombles", created_at: 6.days.ago
    create :hidden_petition, action: "The Wombles are profane", created_at: 1.hour.ago
    create :open_petition, action: "Wombles", created_at: 1.day.ago
  end

  def create_archived_petitions
    create :archived_petition, :closed, action: "Rivers are great", signature_count: 835, opened_at: "2012-01-01", closed_at: "2013-01-01", created_at: "2012-01-01"
    create :archived_petition, :closed, action: "More rivers please", signature_count: 243, opened_at: "2011-04-01", closed_at: "2012-04-01", created_at: "2011-04-01"
    create :archived_petition, :closed, action: "Cry me a river", signature_count: 639, opened_at: "2014-10-01", closed_at: "2015-03-31", created_at: "2014-10-01"
    create :archived_petition, :rejected, action: "Also Rivers", created_at: "2014-10-01"
    create :archived_petition, :hidden, action: "River Island", created_at: "2014-10-01"
  end

  def visit_home_page
    visit "/"
  end

  def search_petitions(query)
    within :search_petitions do
      fill_in "search", with: query
      click_button "Search"
    end
  end

  def expect_search_results_to_be(query, count, results)
    expect(page).to have_current_path("/petitions?q=#{query}")
    expect(page).to have_field("search", with: query)
    expect(page).to have_content("#{count} results")
    expect(page).to have_search_results(results)
  end

  def expect_archive_search_results_to_be(query, count, results)
    expect(page).to have_current_path("/archived/petitions?state=published&q=#{query}")
    expect(page).to have_field("search", with: query)
    expect(page).to have_content("#{count} results")
    expect(page).to have_search_results(results)
  end

  def given_parliament_is_dissolving
    Parliament.instance.update! dissolution_at: 2.weeks.from_now,
      dissolution_heading: "Parliament is dissolving",
      dissolution_message: "This means all petitions will close in 2 weeks",
      dissolution_faq_url: "https://parliament.example.com/parliament-is-closing"
  end

  def given_parliament_has_dissolved
    Parliament.instance.update! dissolution_at: 1.day.ago,
      dissolution_heading: "Parliament is dissolving",
      dissolution_message: "This means all petitions will close in 2 weeks",
      dissolved_heading: "Parliament has been dissolved",
      dissolved_message: "All petitions have been closed",
      dissolution_faq_url: "https://parliament.example.com/parliament-is-closing"
  end

  def given_parliament_is_pending
    Parliament.instance.update!(opening_at: 1.month.from_now)
  end
end
