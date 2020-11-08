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

    it "Submitting valid information redirects me to the discount index page where I
        see the updated information" do
      visit "/merchant/discounts/#{@discount.id}/edit"

      fill_in 'discount[percentage]', with: 10
      click_button 'Update Discount'

      expect(current_path).to eq('/merchant/discounts')
      within "#discount-#{@discount.id}" do
        expect(page).to have_content('Discount updated successfully!')
        expect(page).to have_content('10')
        expect(page).to have_content('10%')
      end
    end

    it "I cannot enter a number outside of 1-100 in the percentage field" do
      visit "/merchant/discounts/#{@discount.id}/edit"

      fill_in 'discount[quantity]', with: 10
      fill_in 'discount[percentage]', with: 101
      click_button 'Update Discount'

      expect(page).to have_content("Edit Discount")
      expect(page).to have_content("Percentage must be a number between 1 and 100.")

      fill_in 'discount[quantity]', with: 10
      fill_in 'discount[percentage]', with: -1
      click_button 'Update Discount'

      expect(page).to have_content("Edit Discount")
      expect(page).to have_content("Percentage must be a number between 1 and 100.")
    end

    it "I cannot enter a number less than 1 in the quantity field" do
      visit "/merchant/discounts/#{@discount.id}/edit"

      fill_in 'discount[quantity]', with: 0
      fill_in 'discount[percentage]', with: 25
      click_button 'Update Discount'

      expect(page).to have_content("Edit Discount")
      expect(page).to have_content("Quantity must be a number greater than 0.")
    end

    it "I cannot leave either field blank" do
      visit "/merchant/discounts/#{@discount.id}/edit"
      fill_in 'discount[quantity]', with: 10
      fill_in 'discount[percentage]', with: ""
      click_button 'Update Discount'

      expect(page).to have_content('Fields cannot be empty')

      visit "/merchant/discounts/"
      fill_in 'discount[quantity]', with: ""
      fill_in 'discount[percentage]', with: 25
      click_button 'Update Discount'

      expect(page).to have_content('Fields cannot be empty')
    end
  end
end