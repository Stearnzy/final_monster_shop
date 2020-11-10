class AddDiscountToItemOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :item_orders, :discount, foreign_key: true
  end
end
