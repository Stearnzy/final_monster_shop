class RemoveDiscountFromItemOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :item_orders, :discount_id
  end
end
