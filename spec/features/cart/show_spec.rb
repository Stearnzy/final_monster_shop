require 'rails_helper'

RSpec.describe 'Cart show' do
  describe 'When I have added items to my cart' do
    describe 'and visit my cart path' do
      before(:each) do
        @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80_203)
        @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80_203)

        @tire = @meg.items.create(name: 'Gatorskins', description: "They'll never pop!", price: 100, image: 'https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588', inventory: 12)
        @paper = @mike.items.create(name: 'Lined Paper', description: 'Great for writing on!', price: 20, image: 'https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png', inventory: 25)
        @pencil = @mike.items.create(name: 'Yellow Pencil', description: 'You can write on paper with it!', price: 2, image: 'https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg', inventory: 100)
        visit "/items/#{@paper.id}"
        click_on 'Add To Cart'
        visit "/items/#{@tire.id}"
        click_on 'Add To Cart'
        visit "/items/#{@pencil.id}"
        click_on 'Add To Cart'
        @items_in_cart = [@paper, @tire, @pencil]

        @user = User.create!(name: 'Mike Dao',
                             address: '123 Main St',
                             city: 'Denver',
                             state: 'CO',
                             zip: '80428',
                             email: 'mike3@turing.com',
                             password: 'ilikefood')

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
      end

      it 'I can empty my cart by clicking a link' do
        visit '/cart'
        expect(page).to have_link('Empty Cart')
        click_on 'Empty Cart'
        expect(current_path).to eq('/cart')
        expect(page).to_not have_css('.cart-items')
        expect(page).to have_content('cart is currently empty')
      end

      it 'I see all items Ive added to my cart' do
        visit '/cart'

        @items_in_cart.each do |item|
          within "#cart-item-#{item.id}" do
            expect(page).to have_link(item.name)
            expect(page).to have_css("img[src*='#{item.image}']")
            expect(page).to have_link(item.merchant.name.to_s)
            expect(page).to have_content("$#{item.price}")
            expect(page).to have_content('1')
            expect(page).to have_content("$#{item.price}")
          end
        end
        expect(page).to have_content('Total: $122')

        visit "/items/#{@pencil.id}"
        click_on 'Add To Cart'

        visit '/cart'

        within "#cart-item-#{@pencil.id}" do
          expect(page).to have_content('2')
          expect(page).to have_content('$4')
        end

        expect(page).to have_content('Total: $124')
      end

      it 'I can increase and decrease the item quantity for each item in my cart' do
        visit '/cart'

        @items_in_cart.each do |item|
          within "#cart-item-#{item.id}" do
            expect(page).to have_button('Increase Quantity')
            expect(page).to have_button('Decrease Quantity')
          end
        end

        within "#cart-item-#{@tire.id}" do
          click_button('Increase Quantity')
        end

        within "#cart-item-#{@tire.id}" do
          expect(page).to have_content('2')
          click_button('Increase Quantity')
        end

        within "#cart-item-#{@tire.id}" do
          expect(page).to have_content('3')
          click_button('Increase Quantity')
        end

        within "#cart-item-#{@tire.id}" do
          expect(page).to have_content('4')
          click_button('Increase Quantity')
        end

        within "#cart-item-#{@tire.id}" do
          expect(page).to have_content('5')
          click_button('Increase Quantity')
        end

        within "#cart-item-#{@tire.id}" do
          expect(page).to have_content('6')
          click_button('Increase Quantity')
        end

        within "#cart-item-#{@tire.id}" do
          expect(page).to have_content('7')
          click_button('Increase Quantity')
        end

        within "#cart-item-#{@tire.id}" do
          expect(page).to have_content('8')
          click_button('Increase Quantity')
        end

        within "#cart-item-#{@tire.id}" do
          expect(page).to have_content('9')
          click_button('Increase Quantity')
        end

        within "#cart-item-#{@tire.id}" do
          expect(page).to have_content('10')
          click_button('Increase Quantity')
        end

        within "#cart-item-#{@tire.id}" do
          expect(page).to have_content('11')
          click_button('Increase Quantity')
        end

        within "#cart-item-#{@tire.id}" do
          expect(page).to have_content('12')
          click_button('Increase Quantity')
        end

        expect(page).to have_content('There are no more items in stock!')

        within "#cart-item-#{@paper.id}" do
          expect(page).to have_content('1')
          click_button('Decrease Quantity')
        end

        expect(page).to_not have_selector("#cart-item-#{@paper.id}")
      end
    end
  end

  describe "When I haven't added anything to my cart" do
    describe 'and visit my cart show page' do
      it 'I see a message saying my cart is empty' do
        visit '/cart'
        expect(page).to_not have_css('.cart-items')
        expect(page).to have_content('cart is currently empty')
      end

      it 'I do NOT see the link to empty my cart' do
        visit '/cart'
        expect(page).to_not have_link('Empty Cart')
      end
    end
  end

  describe "When I have enough items in my cart to trigger a discount" do
    before(:each) do
      @print_shop = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80_203)
      @bike_shop = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80_203)

      @tire = @bike_shop.items.create(name: 'Gatorskins', description: "They'll never pop!", price: 100, image: 'https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588', inventory: 12)
      @paper = @print_shop.items.create(name: 'Lined Paper', description: 'Great for writing on!', price: 20, image: 'https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png', inventory: 25)
      @pencil = @print_shop.items.create(name: 'Yellow Pencil', description: 'You can write on paper with it!', price: 2, image: 'https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg', inventory: 100)

      @five_for_ten = @print_shop.discounts.create(quantity: 5, percentage: 10)
      @ten_for_twenty_five = @print_shop.discounts.create(quantity: 10, percentage: 25)

      visit "/items/#{@paper.id}"
      click_on 'Add To Cart'
      visit "/items/#{@tire.id}"
      click_on 'Add To Cart'
      visit "/items/#{@pencil.id}"
      click_on 'Add To Cart'
      @items_in_cart = [@paper, @tire, @pencil]

      @user = User.create!(name: 'Mike Dao',
                           address: '123 Main St',
                           city: 'Denver',
                           state: 'CO',
                           zip: '80428',
                           email: 'mike3@turing.com',
                           password: 'ilikefood')

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    it "I see that discount applied automatically only to that item" do
      visit '/cart'
      within "#cart-item-#{@paper.id}" do
        3.times do
          click_button('Increase Quantity')
        end

        expect(page).to have_content('4')
        expect(page).to_not have_content('-$')

        click_button('Increase Quantity')
        expect(page).to have_content('5')
        expect(page).to have_content('-$10.00')
      end

      within "#cart-item-#{@tire.id}" do
        expect(page).to_not have_content('-$')
      end

      within "#cart-item-#{@pencil.id}" do
        expect(page).to_not have_content('-$')
      end
    end

    it 'Discount gets replaced by better discount when quantity passes threshold' do
      visit '/cart'
      within "#cart-item-#{@paper.id}" do
        8.times do
          click_button('Increase Quantity')
        end

        expect(page).to have_content('9')
        expect(page).to have_content('-$18.00')

        click_button('Increase Quantity')
        expect(page).to have_content('10')
        expect(page).to have_content('-$50.00')
      end
    end

    it "Discount does not apply to other items from same merchant if discount not hit" do
      visit '/cart'

      within "#cart-item-#{@pencil.id}" do
        expect(page).to_not have_content('-$')
      end

      within "#cart-item-#{@paper.id}" do
        4.times do
          click_button('Increase Quantity')
        end
        expect(page).to have_content('-$10.00')
      end

      within "#cart-item-#{@pencil.id}" do
        expect(page).to_not have_content('-$')
      end
    end

    it "Discounts vary between items, even of same merchants" do
      visit '/cart'
      within "#cart-item-#{@paper.id}" do
        9.times do
          click_button('Increase Quantity')
        end

        expect(page).to have_content('-$50.00')
      end

      within "#cart-item-#{@pencil.id}" do
        4.times do
          click_button('Increase Quantity')
        end
        expect(page).to have_content('-$1.00')
      end
    end

    it "shows the total discount" do
      visit '/cart'

      expect(@items_in_cart).to eq([@paper, @tire, @pencil])

      within "#cart-item-#{@paper.id}" do
        3.times do
          click_button('Increase Quantity')
        end
        expect(page).to_not have_content('-$')
      end

      within "#totals" do
        expect(page).to have_content("Total: $182.00")
        expect(page).to_not have_content("You saved")
      end

      within "#cart-item-#{@paper.id}" do
        click_button('Increase Quantity')
      end

      within "#totals" do
        expect(page).to have_content("Total: $202.00")
        expect(page).to have_content("You saved $10.00")
        expect(page).to have_content("After discount: $192.00")
      end
    end
  end
end
