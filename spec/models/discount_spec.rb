require 'rails_helper'

RSpec.describe Discount, type: :model do
  describe "relationships" do
    it { should belong_to :merchant }
    it { should have_many :item_orders }
  end

  describe "validations" do
    it { should validate_presence_of :quantity}
    it { should validate_presence_of :percentage}
  end
end
