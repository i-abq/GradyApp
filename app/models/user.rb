class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
 
  has_many :authored_blueprints, class_name: "Blueprint", foreign_key: :created_by_id, inverse_of: :creator
  has_many :blueprint_snapshots, class_name: "BlueprintSnapshot", foreign_key: :created_by_id, inverse_of: :creator

  # Soft delete functionality
  scope :active, -> { where(disabled_at: nil) }
  scope :disabled, -> { where.not(disabled_at: nil) }
  
  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  
  # Callbacks
  before_validation :normalize_email
  
  # Instance methods
  def active?
    disabled_at.nil?
  end
  
  def disabled?
    disabled_at.present?
  end
  
  def disable!
    update!(disabled_at: Time.current)
  end
  
  def enable!
    update!(disabled_at: nil)
  end
  
  def full_name
    name.presence || email.split('@').first.humanize
  end
  
  # Override devise active_for_authentication to check soft delete
  def active_for_authentication?
    super && active?
  end
  
  # Override devise inactive_message for disabled accounts
  def inactive_message
    disabled? ? :account_disabled : super
  end
  
  private
  
  def normalize_email
    self.email = email.to_s.strip.downcase if email.present?
  end
end
