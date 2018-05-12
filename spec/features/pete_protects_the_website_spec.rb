require "rails_helper"

RSpec.feature "Pete protects the website", js: true do

  # In order to be protect the site from exposure
  # As Pete, the product owner
  # I want to be able to control access to the website

  background do
    login_as_sysadmin
  end

  scenario "Taking the website down" do
    disable_website
    visit_home_page

    expect_page_to_be_the_maintenance_page
  end

  scenario "Password protecting the website" do
    password_protect_website
    visit_home_page

    expect_page_to_have_access_denied
  end

  # #mark step definitions

  def create_sysadmin
    FactoryBot.create(:sysadmin_user, email: "admin@example.com")
  end

  def disable_website
    click_link "Site"
    expect(page).to have_current_path("/admin/site/edit")

    click_link "Access"
    expect(page).to have_current_path("/admin/site/edit?tab=access")

    within :form_group, 1 do
      choose "Yes"
    end

    click_button "Save"
    expect(page).to have_content("Site updated successfully")
  end

  def expect_page_to_have_access_denied
    expect(page).to have_content("HTTP Basic: Access denied")
  end

  def expect_page_to_be_the_maintenance_page
    expect(page).to have_content("Petitions is down for maintenance")
  end

  def login_as_sysadmin
    create_sysadmin

    visit "/admin/login"

    fill_in "Email", with: "admin@example.com"
    fill_in "Password", with: "Letmein1!"

    click_button "Sign in"
    expect(page).to have_current_path("/admin")
  end

  def password_protect_website
    click_link "Site"
    expect(page).to have_current_path("/admin/site/edit")

    click_link "Access"
    expect(page).to have_current_path("/admin/site/edit?tab=access")

    within :form_group, 2 do
      choose "Yes"
    end

    fill_in "Username", with: "petitions"
    fill_in "Password", with: "password"

    click_button "Save"
    expect(page).to have_content("Site updated successfully")
  end

  def visit_home_page
    visit "https://test.epetitions.website:3443/"
  end
end
