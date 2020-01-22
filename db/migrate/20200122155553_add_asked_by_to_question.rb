class AddAskedByToQuestion < ActiveRecord::Migration[6.0]
  def change
    add_column :questions, :asking_id, :integer
  end
end
