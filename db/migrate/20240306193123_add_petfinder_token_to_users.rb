class AddPetfinderTokenToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :petfinder_token, :string, null: false, default: ''
  end
end
