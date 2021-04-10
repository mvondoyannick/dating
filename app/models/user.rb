class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :name, presence: {message: "Please insert your name"}
  geocoded_by :address
  after_validation :geocode
  has_one_attached :avatar
  before_save :add_default_avatar, if: :new_record?
  before_save :set_token, if: :new_record?
  has_many :posts
  has_many :friend

  private
  def address
    [longitude, latitude].compact.join(', ')
  end

  def set_token
    self.token = SecureRandom.hex
  end

  # add avatar from link with Faker
  def add_default_avatar
    require 'open-uri'
    url = URI.parse(Faker::Avatar.image)
    puts "URL: #{url}"
    filename = File.basename(url.path)
    puts "FILENAME: #{filename}"
    file = URI.open(url)
    unless avatar.attached?
      avatar.attach(
        io: file, filename: filename
      )
    end
  end

end
