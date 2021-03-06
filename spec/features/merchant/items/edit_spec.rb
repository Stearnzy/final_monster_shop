require 'rails_helper'

describe 'merchant index page', type: :feature do
  describe 'As a merchant employee' do
    before :each do
      @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Richmond', state: 'VA', zip: 80203)
      @tire = @bike_shop.items.create(name: 'Gatorskins', description: "They'll never pop!", price: 100, image: 'https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588', inventory: 125)
      @chain = @bike_shop.items.create(name: "Chain", description: "It'll never break!", price: 50, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 55)
      @pedal = @bike_shop.items.create(name: "Pedal", description: "Step on it", price: 10, image: "https://keyassets.timeincuk.net/inspirewp/live/wp-content/uploads/sites/11/2020/06/meow.jpg", inventory: 374)
      @reflector = @bike_shop.items.create(name: "Reflector", description: "They'll see you", price: 200, image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcStDVPL-iMrlZHu5mai-EXeyDH-wH2r9nBeFw&usqp=CAU", inventory: 324)

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

    it 'each item has an edit button' do
      visit '/merchant/items'

      within "#item-#{@tire.id}" do
        expect(page).to have_button("Edit")
      end
      within "#item-#{@chain.id}" do
        expect(page).to have_button("Edit")
      end
      within "#item-#{@pedal.id}" do
        expect(page).to have_button("Edit")
      end
      within "#item-#{@reflector.id}" do
        expect(page).to have_button("Edit")
      end
    end

    it 'click edit button, taken to edit item form with prepopulated info, rules for adding a new item still apply' do
      visit '/merchant/items'

      within "#item-#{@tire.id}" do
        click_button("Edit")
      end
      expect(current_path).to eq("/merchant/items/#{@tire.id}/edit")
      expect(page).to have_content('Edit Item')
      expect(find_field('item[name]').value).to eq("#{@tire.name}")
      expect(find_field('item[description]').value).to eq("#{@tire.description}")
      expect(find_field('item[image]').value).to eq("#{@tire.image}")
      expect(find_field('item[price]').value).to eq("#{@tire.price}")
      expect(find_field('item[inventory]').value).to eq("#{@tire.inventory}")
    end

    it 'when form is submitted I am taken back to my items page and I see a flash message indicating image is updated' do
      visit "/merchant/items/#{@tire.id}/edit"

      fill_in "item[description]", with: "They might pop..."
      fill_in "item[price]", with: "90"
      click_button('Update Item')

      expect(current_path).to eq('/merchant/items')

      within "#item-#{@tire.id}" do
        expect(page).to have_content('90')
        expect(page).to have_content('They might pop...')
        expect(page).to have_content('Active')
      end

      expect(page).to have_content('Your item has been updated')
    end

    it 'image field is left blanc there is a placeholder image for the thumbnail' do
      visit "/merchant/items/#{@tire.id}/edit"
      fill_in "item[image]", with: ""
      click_button('Update Item')

      within "#item-#{@tire.id}" do
        expect(page).to have_css("img[src*='https://snellservices.com/wp-content/uploads/2019/07/image-coming-soon.jpg']")
      end
    end

    it 'Price must be greater than $0.00' do
      visit "/merchant/items/#{@tire.id}/edit"

      fill_in 'item[name]', with: "Helmet"
      fill_in 'item[price]', with: "0"
      fill_in 'item[inventory]', with: "10"
      click_button('Update Item')

      expect(page).to have_content('Price must be greater than 0')
    end

    it 'Inventory cannot be less than 0' do
      visit "/merchant/items/#{@tire.id}/edit"

      fill_in 'item[name]', with: "Helmet"
      fill_in 'item[description]', with: "Safety First!"
      fill_in 'item[image]', with: "https://i.shgcdn.com/944e4e88-f81a-4975-b2a2-c9beb2d3bcf1/-/format/auto/-/preview/3000x3000/-/quality/lighter/"
      fill_in 'item[price]', with: "25"
      fill_in 'item[inventory]', with: "-5"
      click_button('Update Item')

      expect(page).to have_content('Inventory cannot be below 0.')
    end

    it 'if any data is incorrect or missing I am returned to the form, flash message appears, fields are repopulated' do
      visit "/merchant/items/#{@tire.id}/edit"

      fill_in "item[name]", with: ""
      fill_in "item[description]", with: ""
      click_button('Update Item')

      expect(page).to have_content('Edit Item')
      expect(page).to have_content("Name can't be blank, Description can't be blank")
      expect(find_field('item[name]').value).to eq("#{@tire.name}")
      expect(find_field('item[description]').value).to eq("#{@tire.description}")
      expect(find_field('item[image]').value).to eq("#{@tire.image}")
      expect(find_field('item[price]').value).to eq("#{@tire.price}")
      expect(find_field('item[inventory]').value).to eq("#{@tire.inventory}")
    end
  end
end
