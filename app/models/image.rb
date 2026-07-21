class Image < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  has_many :captions, dependent: :destroy
end
