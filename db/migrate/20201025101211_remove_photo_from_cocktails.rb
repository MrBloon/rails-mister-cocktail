class RemovePhotoFromCocktails < ActiveRecord::Migration[6.0]
  def change
    remove_column :cocktails, :photo, :string
  end
end
