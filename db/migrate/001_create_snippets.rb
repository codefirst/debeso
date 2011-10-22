class CreateSnippets < ActiveRecord::Migration
  def self.up
    create_table :snippets do |t|
      t.string :sha1_hash
      t.string :file_name # "name" is used by ActiveRecord ...
    end
  end

  def self.down
    drop_table :snippets
  end
end
