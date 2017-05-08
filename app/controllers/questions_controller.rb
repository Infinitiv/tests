class QuestionsController < ApplicationController
  before_action :set_question, only: [:show]
  
  def show
    @answers = @question.answers.sort_by(&:correct).reverse
  end
  
  def new
    @question = Question.new
  end
  
  def create
    Question.import(question_params[:files])
    redirect_to root_path
  end
  
  private
  
  def set_question
    @question = Question.find(params[:id])
  end
  
  def question_params
    params.require(:question).permit(files: [])
  end
end
