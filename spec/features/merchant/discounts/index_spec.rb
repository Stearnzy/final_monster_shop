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

      @discount = @bike_shop.discounts.create!(quantity: 10, percentage: 5)
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

    it "Submitting valid information redirects me to the discount index page where I
      see the discount's ID, item threshold and percentage of the discount" do
      visit '/merchant/discounts'
      expect(page).to have_content('My Discounts')
      expect(page).to have_content('Discount ID')
      expect(page).to have_content('Minimum Quantity')
      expect(page).to have_content('Percent Off')

      within "#discount-#{@discount.id}" do
        expect(page).to have_content("#{@discount.id}")
        expect(page).to have_content('10')
        expect(page).to have_content('5%')
      end
    end

    it "I see a button to edit a discount" do
      visit "/merchant/discounts"

      within "#discount-#{@discount.id}" do
        expect(page).to have_link('Edit Discount')
      end
    end

    it "Clicking the edit discount button takes me to the edit discout page" do
      visit "/merchant/discounts"
      click_link "Edit Discount"
      expect(current_path).to eq('/merchant/discounts/edit')
    end
  end
end