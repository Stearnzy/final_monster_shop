class RenameDiscountColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :discounts, :discount, :percentage
  end
end
