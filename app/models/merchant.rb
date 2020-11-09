class Merchant <ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :item_orders, through: :items
  has_many :orders, through: :item_orders
  has_many :users, -> { where role: :merchant_employee }
  has_many :discounts

  validates_presence_of :name,
                        :address,
                        :city,
                        :state,
                        :zip


  def no_orders?
    item_orders.empty?
  end

  def item_count
    items.count
  end

  def average_item_price
    items.average(:price)
  end

  def distinct_cities
    item_orders.distinct.joins(:order).pluck(:city)
  end

  def associated_orders
    orders.distinct
  end

  def pending_orders
    associated_orders.where(status: 'pending')
  end

  def toggle_active
    toggle(:active?)
  end

  def all_items_inactive
    items.update_all(active?: false)
  end

  def all_items_active
    items.update_all(active?: true)
  end

  def discount_list
    discounts.order(quantity: :desc)
  end
end
