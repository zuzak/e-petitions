require "rails_helper"

RSpec.feature "User sends feedback", js: true do

  # In order to see the site improved with my suggestions
  # As a user of the site
  # I want to be able to easily send feedback to the site owners

  scenario "Submitting feedback with no details" do
    visit_feedback_page
    submit_feedback

    expect_form_to_have_an_error
    expect_mailbox_to_be_empty
  end

  scenario "Submitting feedback with valid details" do
    visit_feedback_page
    fill_in_feedback_form
    submit_feedback

    expect_page_to_show_thank_you_message
    expect_mailbox_not_to_be_empty
    expect_message_to_have_the_right_content
  end

  # #mark step definitions

  def expect_form_to_have_an_error
    expect(page).to have_content("Comments must be completed")
  end

  def expect_mailbox_not_to_be_empty
    expect(mailbox_for("petitionscommittee@epetitions.website")).not_to be_empty
  end

  def expect_mailbox_to_be_empty
    expect(mailbox_for("petitionscommittee@epetitions.website")).to be_empty
  end

  def expect_message_to_have_the_right_content
    open_last_email_for("petitionscommittee@epetitions.website")
    expect(current_email).to have_subject "Feedback from the Petitions service"
    expect(current_email).to have_body_text "Comments: I can't sign a petition for some reason"
    expect(current_email).to have_body_text "Link: Some petition"
    expect(current_email).to have_body_text "Email: alice@example.com"
  end

  def expect_page_to_show_thank_you_message
    expect(page).to have_content("Thanks for sending us your feedback")
  end

  def fill_in_feedback_form
    fill_in "Comment", with: "I can't sign a petition for some reason"
    fill_in "Petition title/link", with: "Some petition"
    fill_in "Email address", with: "alice@example.com"
  end

  def submit_feedback
    click_button "Send feedback"
  end

  def visit_feedback_page
    visit "/feedback"
  end
end
