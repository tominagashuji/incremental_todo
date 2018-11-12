class Task < ApplicationRecord
  include AASM

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 2000 }

  validates_datetime :deadline, after: -> { DateTime.current }, allow_blank: true

  enum priority: { low: 1, medium: 2, high: 3 }

  scope :priority_height_page, ->(params) { order('priority desc').page(params[:page]) }
  scope :recent_page, ->(params) { order('created_at desc').page(params[:page]) }
  scope :deadline_asc_page, ->(params) { order('deadline asc').page(params[:page]) }

  def self.ransackable_scopes(_auth_object = nil)
    %i[recent_page deadline_asc_page]
  end

  aasm column: 'status' do
    state :not_started, initial: true
    state :started
    state :completed

    event :start do
      transitions from: %i[not_started completed], to: :started
    end

    event :pend do
      transitions from: :not_started, to: :not_started
      transitions from: :started, to: :started
      transitions from: :completed, to: :completed
    end

    event :complete do
      transitions from: %i[not_started started], to: :completed
    end
  end
end
