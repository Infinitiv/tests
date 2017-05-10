namespace :tests do
  desc "Генерация тестов"
  task all: :environment do
    specialites = ['педиатрия']
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
        questions = subject.questions.includes(:answers).where("'педиатрия' = ANY(tags)")
        pdf.text subject.title, style: :bold, :size => 14
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
end
