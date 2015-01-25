class AddStrIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :str_id, :string
  end
end
