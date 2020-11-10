require 'rails_helper'

describe 'As a visitor' do
  describe 'When I check out from my cart' do
    before(:each) do
      @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80_203)
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80_203)
      @tire = @meg.items.create(name: 'Gatorskins', description: "They'll never pop!", price: 100, image: 'https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588', inventory: 12)
      @paper = @mike.items.create(name: 'Lined Paper', description: 'Great for writing on!', price: 20, image: 'https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png', inventory: 50)
      @pencil = @mike.items.create(name: 'Yellow Pencil', description: 'You can write on paper with it!', price: 2, image: 'https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg', inventory: 100)

      visit "/items/#{@paper.id}"
      click_on 'Add To Cart'
      visit "/items/#{@paper.id}"
      click_on 'Add To Cart'
      visit "/items/#{@tire.id}"
      click_on 'Add To Cart'
      visit "/items/#{@pencil.id}"
      click_on 'Add To Cart'

      @user = User.create!(name: 'Mike Dao',
                           address: '123 Main St',
                           city: 'Denver',
                           state: 'CO',
                           zip: '80428',
                           email: 'mike4@turing.com',
                           password: 'ilikefood',
                           role: 0)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end
    it 'I see all the information about my current cart' do
      visit '/cart'

      click_on 'Checkout'

      within "#order-item-#{@tire.id}" do
        expect(page).to have_link(@tire.name)
        expect(page).to have_link(@tire.merchant.name.to_s)
        expect(page).to have_content("$#{@tire.price}")
        expect(page).to have_content('1')
        expect(page).to have_content('$100')
      end

      within "#order-item-#{@paper.id}" do
        expect(page).to have_link(@paper.name)
        expect(page).to have_link(@paper.merchant.name.to_s)
        expect(page).to have_content("$#{@paper.price}")
        expect(page).to have_content('2')
        expect(page).to have_content('$40')
      end

      within "#order-item-#{@pencil.id}" do
        expect(page).to have_link(@pencil.name)
        expect(page).to have_link(@pencil.merchant.name.to_s)
        expect(page).to have_content("$#{@pencil.price}")
        expect(page).to have_content('1')
        expect(page).to have_content('$2')
      end

      expect(page).to have_content('Total: $142')
    end

    it 'I see a form where I can enter my shipping info' do
      visit '/cart'
      click_on 'Checkout'

      expect(page).to have_field(:name)
      expect(page).to have_field(:address)
      expect(page).to have_field(:city)
      expect(page).to have_field(:state)
      expect(page).to have_field(:zip)
      expect(page).to have_button('Create Order')
    end

    it "If no items in my cart hit a discount, I do not see a discount subtotal
        or an updated grand total" do
      @five_for_ten = @mike.discounts.create(quantity: 5, percentage: 10)
      @ten_for_twenty_five = @mike.discounts.create(quantity: 10, percentage: 25)

      visit '/cart'
      click_link 'Checkout'

      within '#totals' do
        expect(page).to have_content('Total: $142.00')
        expect(page).to_not have_content('Savings:')
        expect(page).to_not have_content('Grand Total:')
      end
    end

    it "If one or more items in my cart hit a discount, I see a discount subtotal
        and an updated grand total" do
      @five_for_ten = @mike.discounts.create(quantity: 5, percentage: 10)
      @ten_for_twenty_five = @mike.discounts.create(quantity: 10, percentage: 25)

      visit '/cart'

      within "#cart-item-#{@paper.id}" do
        8.times do
          click_button('Increase Quantity')
        end
      end

      within "#cart-item-#{@pencil.id}" do
        4.times do
          click_button('Increase Quantity')
        end
      end

      click_link 'Checkout'

      within '#totals' do
        expect(page).to have_content('Total: $310.00')
        expect(page).to have_content('Savings: $51.00')
        expect(page).to have_content('Grand Total: $259.00')
      end
    end
  end
end
