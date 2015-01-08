class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.string :access_token
      t.integer :user_id
      t.datetime :expire_date

      t.timestamps
    end
  end
end
