class AudioFile < ApplicationRecord
  validates :file_path, presence: true
  validates :text, presence: true
  validates :use_count, presence: true

  belongs_to :user

  def increment_use_count!
    self.use_count += 1
    save!
  end
end
