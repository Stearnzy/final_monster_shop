require 'rails_helper'

describe "As a merchant employee" do
  describe "When I visit the discount edit page" do
    before(:each) do
      @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Richmond', state: 'VA', zip: 23137)

      @merch_employee = User.create!({
        name: "Kyle",
        address: "333 Starlight Ave.",
        city: "Bakersville",
        state: "NV",
        zip: '90210',
        email: "kyle@email.com",
        password: "word",
        role: 1,
        merchant_id: @bike_shop.id
        })

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merch_employee)

      @discount = @bike_shop.discounts.create!(quantity: 10, percentage: 5)
    end

    it "I see the quantity and percentage fields prepopulated" do
      visit "/merchant/discounts/#{@discount.id}/edit"

      expect(page).to have_content('Edit Discount')
      expect(find_field('discount[quantity]').value).to eq("#{@discount.quantity}")
      expect(find_field('discount[percentage]').value).to eq("#{@discount.percentage}")
    end
  end
end