
class CreateBooksTable < ActiveRecord::Migration

  def change
    create_table :books do |column|
      column.string :title
    end
  end

end
