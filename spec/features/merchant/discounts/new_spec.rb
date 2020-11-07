require 'rails_helper'

describe "As a merchant employee" do
  describe "When I visit the new discount creation page" do
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
    end

    it "I see a form to enter the discount's required quantity and percentage
        to discount by" do
      visit '/merchant/discounts/new'

      expect(page).to have_content('Create Discount')
      expect(page).to have_field('discount[quantity]')
      expect(page).to have_field('discount[percentage]')
    end
  end
end