class User < ApplicationRecord
  has_many :audio_files

  validates :email, presence: true, uniqueness: true
  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: true

  def self.from_omniauth(auth)
    user = find_or_initialize_by(provider: auth.provider, uid: auth.uid)

    user.update!(
      email: auth.info.email,
      name: auth.info.name,
      image: auth.info.image,
    )

    user
  end
end
