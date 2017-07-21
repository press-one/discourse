class UserIdentity < ActiveRecord::Base
  belongs_to :user, inverse_of: :user_identity

  validates :user, presence: true

  validates :id_card_front, upload_url: true, if: :id_card_front_changed?
  validates :id_card_back, upload_url: true, if: :id_card_back_changed?
  validates :id_card_with_person, upload_url: true, if: :id_card_with_person_changed?

  def upload_id_card_front(upload)
    self.id_card_front = upload.url
    self.save!
  end

  def upload_id_card_back(upload)
    self.id_card_back = upload.url
    self.save!
  end

  def upload_id_card_with_person(upload)
    self.id_card_with_person = upload.url
    self.save!
  end
end

# == Schema Information
#
# Table name: user_identities
#
#  user_id              :integer          not null, primary key
#  id_card_front        :string(255)
#  id_card_back         :string(255)
#  id_card_with_person  :string(255)
#
