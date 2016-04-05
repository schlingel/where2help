class Shift < ApplicationRecord
  has_many :shifts_users
  has_many :users, through: :shifts_users
  belongs_to :event
  validates :volunteers_needed, :starts_at, :ends_at, presence: true

  default_scope { order(starts_at: :asc }
  scope :is_not_full, -> { where("volunteers_needed > volunteers_count") }
end
