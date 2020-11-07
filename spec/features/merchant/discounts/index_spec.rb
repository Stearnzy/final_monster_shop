require 'rails_helper'

describe "As a merchant employee" do
  describe "when I visit the discounts index page" do
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

    it "I see a link to create a discount" do
      visit '/merchant/discounts'
      expect(page).to have_content('All Discounts')
      expect(page).to have_link('Create New Discount')
    end

    it "When I click the create link I am taken to the discount create page" do
      visit '/merchant/discounts'
      click_link('Create New Discount')
      expect(current_path).to eq('/merchant/discounts/new')
    end
  end
end