class Discount < ApplicationRecord
  validates_presence_of :quantity, :percentage

  belongs_to :merchant
  has_many :item_orders
end
