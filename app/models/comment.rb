class Comment < ApplicationRecord
  belongs_to :incident, counter_cache: true
  belongs_to :participant
  has_one :festival, through: :incident
  has_many :revisions, autosave: true, dependent: :destroy
  has_one :previous_revision,
    -> { order(created_at: :desc) },
    class_name: 'Revision'

  validates :participant, presence: true

  before_validation :create_revision, if: :content_changed_before_save?

  scope :not_deleted, -> { where(deleted: false) }
  scope :oldest_first, -> { order(:created_at) }

  def edited?
    revisions_count.positive?
  end

  def mark_as_deleted!
    update!(deleted: true)
  end

  private

  def content_changed_before_save?
    content_changed? && content_was.present?
  end

  def create_revision
    revisions.build(content: content_was,created_at: previous_revision_time)
  end

  def previous_revision_time
    previous_revision&.updated_at || created_at
  end
end
