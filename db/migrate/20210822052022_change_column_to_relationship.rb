class ChangeColumnToRelationship < ActiveRecord::Migration[6.1]
  def change
    rename_column :relationships, :follower_id, :following_id
  end
end
