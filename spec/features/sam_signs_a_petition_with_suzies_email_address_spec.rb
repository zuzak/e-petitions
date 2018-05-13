require "rails_helper"

RSpec.feature "Sam signs a petition with Suzie's email address", js: true do

  # In order to have my say as well as Suzie without needing a seperate email address
  # As Sam, Suzie's partner
  # I want to sign a petition that has already been signed by Suzie

  background do
    create_open_petition
    sign_the_petition_as_suzie
  end

  scenario "Sam can sign the petition with a different name" do
    sign_the_petition(name: "Sam Wibbledon")
    validate_signature_from_email

    expect_page_to_say_that_signature_has_been_added
  end

  scenario "Sam cannot sign the petition again using Suzie's name" do
    sign_the_petition(name: "Suzie Wibbledon")

    expect_email_to_warn_about_a_duplicate_signature
  end

  scenario "Sam cannot sign the petition with a different postcode" do
    sign_the_petition(name: "Sam Wibbledon", postcode: "SW1A 1AA")

    expect_email_to_warn_about_a_duplicate_signature
  end

  scenario "Sarah (Sam's daughter) cannot sign the petition a third time with the same email address" do
    sign_the_petition(name: "Sam Wibbledon")
    validate_signature_from_email
    expect_page_to_say_that_signature_has_been_added

    sign_the_petition(name: "Sarah Wibbledon")
    expect_email_to_warn_about_a_duplicate_signature
  end

  # #mark step definitions

  def confirm_email_address
    click_button "Yes – this is my email address"
    expect(page).to have_content("One more step…")
  end

  def create_open_petition
    create(:open_petition, action: "Do something!")
    create(:location, code: "GB", name: "United Kingdom")

    stub_any_api_request
  end

  def expect_email_to_warn_about_a_duplicate_signature
    open_last_email_for "womboid@wimbledon.com"
    expect(current_email).to have_subject("Duplicate signature of petition")
  end

  def expect_page_to_say_that_signature_has_been_added
    expect(page).to have_content("We've added your signature to the petition")
  end

  def fill_in_signature_form(name, postcode)
    check "I am a British citizen or UK resident"
    fill_in "Name", with: name
    fill_in "Email address", with: "womboid@wimbledon.com"
    select "United Kingdom", from: "signature_location_code"
    fill_in "Postcode", with: postcode
  end

  def sign_the_petition(name: "Suzie Wibbledon", postcode: "SW14 9RQ")
    visit_new_signature_page
    fill_in_signature_form(name, postcode)
    submit_form
    confirm_email_address
  end

  def sign_the_petition_as_suzie
    sign_the_petition(name: "Suzie Wibbledon")
    validate_signature_from_email
    expect_page_to_say_that_signature_has_been_added
  end

  def submit_form
    click_button "Continue"
    expect(page).to have_content("Make sure this is right")
  end

  def validate_signature_from_email
    open_last_email_for "womboid@wimbledon.com"
    click_first_link_in_email
  end

  def visit_new_signature_page
    visit "/petitions?q=do+something"
    click_link "Do something!"
    click_link "Sign this petition"
  end
end
