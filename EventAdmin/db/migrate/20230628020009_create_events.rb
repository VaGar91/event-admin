# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.date :init_date
      t.float :cost
      t.string :location

      t.timestamps
    end
  end
end
