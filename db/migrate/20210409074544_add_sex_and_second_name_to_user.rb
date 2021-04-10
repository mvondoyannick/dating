class AddSexAndSecondNameToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :sex, :string
    add_column :users, :second_name, :string
  end
end
