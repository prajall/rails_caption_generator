class CreateCaptions < ActiveRecord::Migration[8.1]
  def change
    create_table :captions do |t|
      t.references :image, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
