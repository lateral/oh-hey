class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :twitter
      t.string :github
      t.string :remote_id
      t.string :uuid
      t.string :major
      t.string :minor
    end
  end
end
