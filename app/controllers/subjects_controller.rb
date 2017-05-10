class SubjectsController < ApplicationController
  before_action :set_subject, only: [:show]
  
  def index
    @subjects = Subject.order(:title).includes(:questions).load
  end
  
  def show
    @questions = @subject.questions.includes(:answers)
  end
  
  private
  
  def set_subject
    @subject = Subject.find(params[:id])
  end
end
