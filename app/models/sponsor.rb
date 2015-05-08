# == Schema Information
#
# Table name: sponsors
#
#  id               :integer          not null, primary key
#  encrypted_email  :string(255)
#  perishable_token :string(255)
#  petition_id      :integer
#  signature_id     :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null


class Sponsor < ActiveRecord::Base

  include EmailEncrypter
  include PerishableTokenGenerator
  
  # = Relationships =
  belongs_to :petition
  belongs_to :signature

  # = Validations =
  validates :encrypted_email,
            uniqueness: { scope: :petition,
                          message: "Sponsor Emails for Petition should be unique" }
  validates_presence_of :petition, message: "Needs a petition"

end