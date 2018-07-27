
class CreateChaptersTable < ActiveRecord::Migration

  def change
    create_table :chapters do |column|
      column.string :name
      column.integer :ordinal
    end
  end

end
