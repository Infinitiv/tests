class CreateJoinTableSubjectQuestion < ActiveRecord::Migration[5.1]
  def change
    create_join_table :subjects, :questions do |t|
      t.index [:subject_id, :question_id]
      t.index [:question_id, :subject_id]
    end
  end
end
