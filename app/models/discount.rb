class Discount < ApplicationRecord
  validates_presence_of :quantity, :percentage
  validates_numericality_of :quantity, :only_integer => true,
                           :greater_than_or_equal_to => 1,
                           :message => "must be a number greater than 0."
  validates_numericality_of :percentage, :only_integer => true,
                           :greater_than_or_equal_to => 1,
                           :less_than_or_equal_to => 99,
                           :message => "must be a number between 1 and 100."

  belongs_to :merchant
end
