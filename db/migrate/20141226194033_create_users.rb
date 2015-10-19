class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, index: true
      t.string :access_token

      t.timestamps null: false
    end
  end
end
