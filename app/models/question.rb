class Question < ApplicationRecord
  has_and_belongs_to_many :subjects
  has_many :answers, dependent: :destroy
  
  validates :text, presence: true
  
  def self.import(files)
    files.each do |file|
      subject = Subject.create(title: File.basename(file.original_filename, '.*'))
      if File.extname(file.original_filename) == ".txt"
        lines = File.readlines(file.path)
        lines.each do |line|
          if line.first == "#"
            question_create(line, subject)
          else
            answer_create(line, @question)
          end
        end
      else
        spreadsheet = open_spreadsheet(file)
        (1..spreadsheet.last_row).each do |row|
          if row[0] == 1
            question_create(row[1], subject)
          else
            answer_create(row[1], @question)
          end
        end
      end
    end
    
  end
  
  private
  
  def self.question_create(text, subject)
    if text.first == "#"
      text =  text.last(text.length - 1).strip
      tags = ['первичная аккредитация']
    else
      text.strip
      tags = ['итоговая государственная аттестация']
    end
    @question = Question.create(text: text, tags: tags)
    @question.subjects << subject
  end
  
  def self.answer_create(text, question)
    correct = text.first == "+" ? true : false
    text = text.last(text.length - 1).strip
    answer = question.answers.create(text: text, correct: correct)
  end
  
  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".ods" then Roo::Openoffice.new(file.path)
    when ".csv" then Roo::CSV.new(file.path)
    when ".xls" then Roo::Excel.new(file.path)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
