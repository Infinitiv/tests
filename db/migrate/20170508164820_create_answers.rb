class CreateAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :answers do |t|
      t.references :question, foreign_key: true
      t.text :text
      t.integer :correct, default: 0

      t.timestamps
    end
  end
end
