class UpdateDistanceFieldUsers < ActiveRecord::Migration
  def change
    change_column :users, :distance, :string
  end
end
