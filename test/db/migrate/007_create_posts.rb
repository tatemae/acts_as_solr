class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts, :force => true do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :posts
  end
end
