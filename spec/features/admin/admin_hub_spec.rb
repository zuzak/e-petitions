require "rails_helper"

RSpec.feature "Admin hub page", js: true do

  # In order to help administrators see the next actions they need to take
  # As any moderator user
  # I want to view a page which lists totals for actionable list and links to them

  background do
    login_as_moderator
  end

  scenario "I can see a total of petitions needing moderation and link to them" do
    create_petitions_for_moderation
    visit_admin_home_page

    expect_page_to_have_a_moderation_summary
  end

  scenario "I can see when there are petitions that are overdue moderation" do
    create_petition :sponsored, :overdue, count: 5
    visit_admin_home_page

    expect_the_moderation_summary_to_be_red(count: 5)
  end

  scenario "I can see when there are petitions that are nearly overdue moderation" do
    create_petition :sponsored, :nearly_overdue, count: 5
    visit_admin_home_page

    expect_the_moderation_summary_to_be_amber(count: 5)
  end

  scenario "I can see when there are petitions that have recently joined the moderation queue" do
    create_petition :sponsored, :recent, count: 5
    visit_admin_home_page

    expect_the_moderation_summary_to_be_green(count: 5)
  end

  scenario "I can see when there are petitions in moderation that are tagged" do
    create_petition :sponsored, :tagged, count: 1
    visit_admin_home_page

    expect_tagged_petitions_to_show(count: 1)
  end

  scenario "I can click through to see lists of matching petitions" do
    create_petition :sponsored, count: 12
    visit_admin_home_page
    click_the_moderation_queue_link

    expect_to_be_on_the_moderation_queue_page
  end

  # #mark step definitions

  def click_the_moderation_queue_link
    click_link "12 Moderation queue"
  end

  def create_moderator
    FactoryBot.create(:moderator_user, email: "moderator@example.com")
  end

  def create_petition(factory = "open", *traits, count: 1)
    count.times { FactoryBot.create(:"#{factory}_petition", *traits) }
  end

  def create_petitions_for_moderation
    create_petition :sponsored, count: 20
    create_petition :awaiting_response, count: 12
    create_petition :scheduled_debate, count: 5
    create_petition :awaiting_debate, count: 3
  end

  def expect_page_to_have_a_moderation_summary
    expect(page).to have_content("20 Moderation queue")
    expect(page).to have_content("12 Government response queue")
    expect(page).to have_content("8 Debate queue")
    expect(page).to have_content("All Petitions (40)")
  end

  def expect_tagged_petitions_to_show(count:)
    within(:css, ".tagged-in-moderation") do
      expect(page).to have_content(count.to_s)
    end
  end

  def expect_the_moderation_summary_to_be(count:, state:, style:)
    expect(page).to have_css(".#{state}-in-moderation.queue-#{style}")
    expect(page).to have_css(".moderation .panel.queue-#{style}")

    within(:css, ".#{state}-in-moderation") do
      expect(page).to have_content(count.to_s)
    end
  end

  def expect_the_moderation_summary_to_be_amber(count: 0)
    expect_the_moderation_summary_to_be(count: count, state: "nearly-overdue", style: "caution")
  end

  def expect_the_moderation_summary_to_be_green(count: 0)
    expect_the_moderation_summary_to_be(count: count, state: "recently", style: "stable")
  end

  def expect_the_moderation_summary_to_be_red(count: 0)
    expect_the_moderation_summary_to_be(count: count, state: "overdue", style: "danger")
  end

  def expect_to_be_on_the_moderation_queue_page
    expect(page).to have_current_path("/admin/petitions?state=in_moderation")
  end

  def login_as_moderator
    create_moderator

    visit "/admin/login"

    fill_in "Email", with: "moderator@example.com"
    fill_in "Password", with: "Letmein1!"

    click_button "Sign in"
    expect(page).to have_current_path("/admin")
  end

  def visit_admin_home_page
    visit "/admin"
  end
end
