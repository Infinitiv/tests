class Question < ApplicationRecord
  has_and_belongs_to-many :subjects
  
  validates :text, presence: true
end
