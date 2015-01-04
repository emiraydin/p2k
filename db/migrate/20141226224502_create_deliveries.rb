class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.references :user, index: true
      t.string :kindle_email
      t.column :frequency, :integer, default: 0
      t.column :day, :integer, default: 7
      t.integer :hour
      t.string :time_zone
      t.column :option, :integer, default: 0
      t.integer :count
      t.boolean :archive_delivered, default: false

      t.timestamps
    end
  end
end
