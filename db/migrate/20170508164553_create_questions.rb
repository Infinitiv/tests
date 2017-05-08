class CreateQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :questions do |t|
      t.text :text
      t.string :tags, array: true

      t.timestamps
    end
    add_index :questions, :tags, using: 'gin'
  end
end
