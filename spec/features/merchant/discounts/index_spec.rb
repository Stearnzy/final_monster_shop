require 'rails_helper'

describe "As a merchant employee" do
  describe "when I visit the discounts index page" do
    it "I see a link to create a discount" do
      visit '/merchant/discounts'
      expect(page).to have_link('Create New Discount')
    end

    it "When I click the create link I am taken to a form page where I see a form
        to enter the discount's required quantity and percentage to discount by" do
      visit '/merchant/discounts'
      click_link('Create New Discount')

      expect(current_path).to eq('/merchant/discounts/new')
      expect(page).to have_field(:quantity)
      expect(page).to have_field(:discount)
    end
  end
end