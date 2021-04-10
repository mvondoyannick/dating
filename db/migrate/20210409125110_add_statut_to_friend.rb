class AddStatutToFriend < ActiveRecord::Migration[6.0]
  def change
    add_column :friends, :status, :string
  end
end
