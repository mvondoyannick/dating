class AddColorToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :color, :string
    add_column :users, :relationship, :string
    add_column :users, :gender, :string
    add_column :users, :job, :string
    add_column :users, :phone, :string
  end
end
