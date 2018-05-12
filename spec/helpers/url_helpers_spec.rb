require 'rails_helper'

RSpec.describe "url helpers", type: :helper do
  let(:headers) { helper.request.env }

  describe "#admin_root_url" do
    context "when on the public website" do
      before do
        headers["HTTP_HOST"]   = "test.epetitions.website:3443"
        headers["HTTPS"]       = "on"
      end

      it "generates a moderation website url" do
        expect(helper.admin_root_url).to eq("https://test-moderate.epetitions.website:3443/admin")
      end
    end
  end

  describe "#home_url" do
    context "when on the moderation website" do
      before do
        headers["HTTP_HOST"]   = "test-moderate.epetitions.website:3443"
        headers["HTTPS"]       = "on"
      end

      it "generates a public website url" do
        expect(helper.home_url).to eq("https://test.epetitions.website:3443/")
      end
    end
  end
end
