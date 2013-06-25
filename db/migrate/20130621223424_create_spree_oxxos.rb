class CreateSpreeOxxos < ActiveRecord::Migration
  def change
    create_table :spree_oxxos do |t|
      t.text :order_ids
      t.string :state
      t.datetime :completed_at
      t.datetime :failed_at
      t.string :oxxo_file_file_name
      t.string :oxxo_file_content_type
      t.integer :oxxo_file_file_size
      t.datetime :oxxo_file_updated_at
      t.timestamps
    end
  end
end
