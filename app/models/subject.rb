class Subject < ApplicationRecord
  has_and_belongs_to_many :questions
  has_many :answers, through: :questions
  
  validates :title, presence: true
end
