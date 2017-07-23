require 'facepp_api'

class UserIdentity < ActiveRecord::Base
  belongs_to :user, inverse_of: :user_identity

  validates :user, presence: true

  validates :id_card_front, upload_url: true, if: :id_card_front_changed?
  validates :id_card_back, upload_url: true, if: :id_card_back_changed?
  validates :id_card_with_person, upload_url: true, if: :id_card_with_person_changed?

  before_save :validate_identity

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

  protected

  def validate_identity
    if id_card_front_changed? || id_card_back_changed? || id_card_with_person_changed?
      unless id_card_front.blank? || id_card_back.blank? || id_card_with_person.blank?
        self.validating_status = 1
        self.error_message = ""
        if validate_id_card_front &&
           validate_id_card_back &&
           validate_id_card_with_person &&
           validate_id_card_unique
          self.validating_status = 3
        else
          self.validating_status = 2
        end
      else
        self.error_message = "All id card photos should be uploaded"
      end
    end
  end

  def validate_id_card_front
    result = FaceppApi::ocr_id_card :front, image_path(id_card_front)
    if result[:error_message].blank?
      self.id_card_number = result[:id_card_number]
      self.realname = result[:name]
    else
      self.error_message = result[:error_message]
    end
    self.error_message.blank?
  end

  def validate_id_card_back
    result = FaceppApi::ocr_id_card :back, image_path(id_card_back)
    unless result[:error_message].blank?
      self.error_message = result[:error_message]
    end
    self.error_message.blank?
  end

  def validate_id_card_with_person
    result = FaceppApi::compare image_path(id_card_front), image_path(id_card_with_person)
    if result[:error_message].blank?
      self.confidence = result[:confidence]
    else
      self.error_message = result[:error_message]
    end
    self.error_message.blank?
  end

  def validate_id_card_unique
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
#  realname             :string(32)
#  confidence           :integer
#  error_message        :string(255)
#
