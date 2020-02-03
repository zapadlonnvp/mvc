class AddUserToQuestion < ActiveRecord::Migration[6.0]
  def change
    add_reference :questions, :user, foreign_key: true, on_delete: :nullify
  end
end
