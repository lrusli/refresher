class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps null: false
    end
    # Indeces for faster retrieval.
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    # Unique multi key index so a user can't follow another more than once.
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
