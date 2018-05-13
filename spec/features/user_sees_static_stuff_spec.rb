require "rails_helper"

RSpec.feature "User views static pages", js: true do

  # In order to let users know about the site
  # I can navigate to how E-petitions works and help pages

  scenario "I navigate to the home page" do
    visit_home_page

    expect_page_to_be_the_home_page
  end

  scenario "I navigate to 'How petitions work' page" do
    visit_home_page
    click_how_petitions_work_link

    expect_page_to_be_the_how_petitions_work_page
  end

  scenario "I navigate to 'Privacy and cookies' page" do
    visit_home_page
    click_privacy_and_cookies_link

    expect_page_to_be_the_privacy_and_cookies_page
  end

  # #mark step definitions

  def visit_home_page
    visit "/"
  end

  def click_how_petitions_work_link
    click_link "How petitions work"
  end

  def click_privacy_and_cookies_link
    click_link "Privacy and cookies"
  end

  def expect_page_to_be_the_home_page
    expect(page).to have_current_path("/")
    expect(page).to have_title("Petitions - UK Government and Parliament")
  end

  def expect_page_to_be_the_how_petitions_work_page
    expect(page).to have_current_path("/help")
    expect(page).to have_title("How petitions work")
  end

  def expect_page_to_be_the_privacy_and_cookies_page
    expect(page).to have_current_path("/privacy")
    expect(page).to have_title("Privacy and cookies")
  end
end
