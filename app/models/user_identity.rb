require 'facepp_api'

class UserIdentity < ActiveRecord::Base
  belongs_to :user, inverse_of: :user_identity

  validates :user, presence: true

  validates :id_card_front, upload_url: true, if: :id_card_front_changed?
  validates :id_card_back, upload_url: true, if: :id_card_back_changed?
  validates :id_card_with_person, upload_url: true, if: :id_card_with_person_changed?

  validates :passport_cover, upload_url: true, if: :passport_cover_changed?
  validates :passport_content, upload_url: true, if: :passport_content_changed?
  validates :passport_with_person, upload_url: true, if: :passport_with_person_changed?
  validates :passport_country, inclusion: { in: 1...1000 }, if: :passport_country_changed?

  before_save :verify_identity_by_id_card
  before_save :verify_identity_by_passport
  after_save :verify_user

  def verify_id_card
    if verify_id_card_front &&
       verify_id_card_back &&
       verify_id_card_with_person &&
       verify_id_card_unique
      self.validating_status = 3
    else
      self.validating_status = 2
    end
    save
  end

  protected

  def verify_user
    if validating_status_changed?
      (validating_status >= 3) ? user.verify : user.unverify
    end
  end

  def verify_identity_by_passport
    passport_attrs = ["passport_cover",
                      "passport_content",
                      "passport_with_person",
                      "passport_country",
                      "passport_number",
                      "passport_name"]

    if (passport_attrs & changed).any?
      self.validating_status = 1

      unless passport_attrs.map {|attr| send(attr).blank?}.include? true
        identity = UserIdentity.find_by passport_country: passport_country,
                                        passport_number: passport_number
        if identity && identity != self
          self.error_message = "Passport existed"
          self.validating_status = 2
        end
      end
    end
  end

  def verify_identity_by_id_card
    if id_card_front_changed? || id_card_back_changed? || id_card_with_person_changed?
      unless id_card_front.blank? || id_card_back.blank? || id_card_with_person.blank?
        self.validating_status = 1
        self.error_message = ""
        Jobs.enqueue_in 5.seconds, :verify_id_card, user_id: self.user_id
      else
        self.validating_status = 2
        self.error_message = "All id card photos should be uploaded"
      end
    end
  end

  def verify_id_card_front
    result = FaceppApi::ocr_id_card :front, image_path(id_card_front)
    if result[:error_message].blank?
      self.id_card_number = result[:id_card_number]
      self.id_card_name = result[:name]
    else
      self.error_message = result[:error_message]
    end
    self.error_message.blank?
  end

  def verify_id_card_back
    result = FaceppApi::ocr_id_card :back, image_path(id_card_back)
    unless result[:error_message].blank?
      self.error_message = result[:error_message]
    end
    self.error_message.blank?
  end

  def verify_id_card_with_person
    result = FaceppApi::compare image_path(id_card_front), image_path(id_card_with_person)
    if result[:error_message].blank?
      self.confidence = result[:confidence]
    else
      self.error_message = result[:error_message]
    end
    self.error_message.blank?
  end

  def verify_id_card_unique
    identity = UserIdentity.find_by_id_card_number id_card_number
    if identity && identity != self
      self.error_message = "ID Card Number exist"
    end
    self.error_message.blank?
  end

  def image_path(upload_url)
    "#{Rails.public_path}#{upload_url}"
  end
end

# == Schema Information
#
# Table name: user_identities
#
#  user_id              :integer          not null, primary key
#  validating_status    :integer          default(0), not null
#                                         1=Validating;2=Validate fail;3=Validate success
#  id_card_front        :string(255)
#  id_card_back         :string(255)
#  id_card_with_person  :string(255)
#  id_card_number       :string(32)
#  id_card_name         :string(32)
#  passport_cover       :string(255)
#  passport_content     :string(255)
#  passport_with_person :string(255)
#  passport_country     :integer
#  passport_number      :string(32)
#  passport_name        :string(32)
#  confidence           :integer
#  error_message        :string(255)
#
