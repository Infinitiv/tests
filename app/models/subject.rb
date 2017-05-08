class Subject < ApplicationRecord
  has_and_belongs_to-many :questions
  
  validates :title, presence: true
end
