namespace :tests do
  desc "Генерация тестов"
  task all: :environment do
    specialites = ['лечебное дело', 'педиатрия']
    specialites.each do |speciality|
      subjects = Subject.order(:title).joins(:questions).where("\'#{speciality}\' = ANY(tags)").uniq
      subjects.each do |subject|
        title = "Тесты ГИА #{speciality} (#{subject.title})"
        pdf = Prawn::Document.new(page_size: "A4", :info => {
          :Title => title,
          :Author => "Vladimir Markovnin",
          :Subject => "ГИА ИвГМА",
          :Creator => "ИвГМА",
          :Producer => "Prawn",
          :CreationDate => Time.now }
          )
        pdf.font_families.update("Ubuntu" => {
          :normal => "#{Rails.root}/vendor/fonts/Ubuntu-R.ttf",
          :italic => "#{Rails.root}/vendor/fonts/Ubuntu-RI.ttf",
          :bold => "#{Rails.root}/vendor/fonts/Ubuntu-B.ttf"
          })
        pdf.font "Ubuntu"
        n = 0
        questions = subject.questions.includes(:answers).where("\'#{speciality}\' = ANY(tags)").uniq
        pdf.text "#{subject.title} (#{questions.count} вопросов)", style: :bold, :size => 14
        pdf.move_down 10
        questions.each do |question|
          n += 1
          puts "#{subject.title} - #{n}"
          pdf.text "%04d" % n + ". #{question.text}", style: :italic, size: 12
          pdf.move_down 10
          m = 0
          question.answers.order(:correct).reverse.each do |answer|
            m += 1
            pdf.text "#{m}. #{answer.text}", size: 12
            pdf.move_down 10
          end
        end
        string = "Страница <page> из <total>"
        options = {:at => [pdf.bounds.right - 150, 0], :width => 150, :align => :center, :start_count_at => 1}
        pdf.number_pages string, options
        pdf.render_file "public/#{title}.pdf"
      end
    end
  end
  
  desc "Генерация вариантов"
  task sample: :environment do
    specialites = ['лечебное дело', 'педиатрия']
    specialites.each do |speciality|
      questions = Question.where("\'#{speciality}\' = ANY(tags)").uniq
      (1..10).each do |i|
        h = {}
        questions_prime = questions.select{|q| q.tags.include?('приоритет')}
        questions_second = questions.select{|q| !q.tags.include?('приоритет')}
        title = "ГИА #{Time.now.to_date.year} (#{speciality}) - вариант #{i}"
        pdf = Prawn::Document.new(page_size: "A4", :info => {
          :Title => title,
          :Author => "Vladimir Markovnin",
          :Subject => "ГИА ИвГМА",
          :Creator => "ИвГМА",
          :Producer => "Prawn",
          :CreationDate => Time.now }
          )
        pdf.font_families.update("Ubuntu" => {
          :normal => "#{Rails.root}/vendor/fonts/Ubuntu-R.ttf",
          :italic => "#{Rails.root}/vendor/fonts/Ubuntu-RI.ttf",
          :bold => "#{Rails.root}/vendor/fonts/Ubuntu-B.ttf"
          })
        pdf.font "Ubuntu"
        n = 0
        pdf.text title, style: :bold, :size => 14
        pdf.move_down 8
        questions_prime.sample(70).each do |question|
          n += 1
          puts "Вариант #{i} - #{n}"
          pdf.text "%04d" % n + ". #{question.text}", style: :italic, size: 12
          pdf.move_down 8
          m = 0
          question.answers.shuffle.each do |answer|
            m += 1
            pdf.text "#{m}. #{answer.text}", size: 12
            h[n] = m if answer.correct == 1
            pdf.move_down 8
          end
        end
        questions_second.sample(30).each do |question|
          n += 1
          puts "Вариант #{i} - #{n}"
          pdf.text "%04d" % n + ". #{question.text}", style: :italic, size: 12
          pdf.move_down 8
          m = 0
          question.answers.shuffle.each do |answer|
            m += 1
            pdf.text "#{m}. #{answer.text}", size: 12
            h[n] = m if answer.correct == 1
            pdf.move_down 8
          end
        end
        string = "Страница <page> из <total>"
        options = {:at => [pdf.bounds.right - 150, 0], :width => 150, :align => :center, :start_count_at => 1}
        pdf.number_pages string, options
        pdf.render_file "public/#{title}.pdf"
        
        title = "ГИА #{Time.now.to_date.year} (#{speciality}) - вариант #{i} - ответы"
        pdf = Prawn::Document.new(page_size: "A4", :info => {
          :Title => title,
          :Author => "Vladimir Markovnin",
          :Subject => "ГИА ИвГМА",
          :Creator => "ИвГМА",
          :Producer => "Prawn",
          :CreationDate => Time.now }
          )
        pdf.font_families.update("Ubuntu" => {
          :normal => "#{Rails.root}/vendor/fonts/Ubuntu-R.ttf",
          :italic => "#{Rails.root}/vendor/fonts/Ubuntu-RI.ttf",
          :bold => "#{Rails.root}/vendor/fonts/Ubuntu-B.ttf"
          })
        pdf.font "Ubuntu"
        pdf.text title, style: :bold, :size => 14
        pdf.move_down 8
        table_content = {}
        h.each do |q, a|
          i = (q - 1)/10.floor 
          table_content[i] ||= ''
          s = "%03d" % q
          table_content[i] += "#{s} - #{a}\n"
        end
        pdf.table([table_content.values])
        string = "Страница <page> из <total>"
        options = {:at => [pdf.bounds.right - 150, 0], :width => 150, :align => :center, :start_count_at => 1}
        pdf.number_pages string, options
        pdf.render_file "public/#{title}.pdf"
      end
    end
  end
end
