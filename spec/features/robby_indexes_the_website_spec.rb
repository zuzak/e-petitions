require "rails_helper"

RSpec.feature "Robby indexes the website", js: true do

  # In order to provide relevant links
  # As Robby, a search engine webcrawler
  # I want to be able to index the correct pages

  background do
    create_open_petition
  end

  scenario "Fetching a petition page" do
    search_for_petition
    visit_petition_page

    expect_page_not_to_have_robots_meta_tag
  end

  scenario "Fetching a new signature page" do
    search_for_petition
    visit_petition_page
    visit_signature_page

    expect_page_to_have_robots_meta_tag
  end

  scenario "Fetching an admin page" do
    visit_admin_page

    expect_page_to_have_robots_meta_tag
  end

  # #mark step definitions

  def create_open_petition
    FactoryBot.create(:open_petition, action: "Do something!")
  end

  def expect_page_not_to_have_robots_meta_tag
    expect(page).not_to have_selector(:noindex, visible: false)
  end

  def expect_page_to_have_robots_meta_tag
    expect(page).to have_selector(:noindex, visible: false)
  end

  def search_for_petition
    visit "/petitions?q=do+something"
  end

  def visit_admin_page
    visit "/admin"
  end

  def visit_petition_page
    click_link "Do something!"
    expect(page).to have_link("Sign this petition")
  end

  def visit_signature_page
    click_link "Sign this petition"
    expect(page).to have_content("Sign petition")
  end
end
