class Question < ApplicationRecord
  has_and_belongs_to_many :subjects
  has_many :answers, dependent: :destroy
  
  validates :text, presence: true
  
  def self.import(files, tags)
    tags_custom = tags.split(',')
    files.each do |file|
      if File.extname(file.original_filename) == ".txt"
        subject = Subject.find_by_title(File.basename(file.original_filename, '.*').strip) || Subject.create(title: File.basename(file.original_filename, '.*').strip)
        lines = File.readlines(file.path, encoding: 'cp1251')
        lines.each do |line|
          if line.first == "#"
            text =  line.last(line.length - 1).strip
            tags = tags_custom
            tags +=  ['первичная аккредитация']
            @question = Question.create(text: text, tags: tags)
            @question.subjects << subject
          else
            correct = line.first == "+" ? 1 : 0
            text = line.last(line.length - 1).strip
            answer = @question.answers.create(text: text, correct: correct)
          end
        end
      else
        spreadsheet = open_spreadsheet(file)
        (1..spreadsheet.last_row).each do |i|
          row = spreadsheet.row(i)
          tags = tags_custom
          unless row[0] == nil
            case row[2]
            when 1.to_s
              tags += ['лечебное дело']
            when 2.to_s
              tags += ['педиатрия']
            when 3.to_s
              tags += ['стоматология']
            else
              tags += ['лечебное дело', 'педиатрия']
            end
            subject = Subject.find_by_title(row[0].strip) || Subject.create(title: row[0].strip)
            text = row[1]
            tags += ['итоговая государственная аттестация']
            @question = Question.create(text: text, tags: tags)
            @question.subjects << subject
          else
            correct = row[2] == 1.to_s ? 1 : 0
            text = row[1]
            answer = @question.answers.create(text: text, correct: correct)
          end
        end
      end
    end
    
  end
  
  private
  
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
