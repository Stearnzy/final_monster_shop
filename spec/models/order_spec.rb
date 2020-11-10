require 'rails_helper'

describe Order, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
  end

  describe 'relationships' do
    it { should have_many :item_orders }
    it { should have_many(:items).through(:item_orders) }
    it { should belong_to :user }
  end

  describe 'instance methods' do
    before :each do
      @user = User.create!(name: 'Mike Dao',
                           address: '123 Main St',
                           city: 'Denver',
                           state: 'CO',
                           zip: '80428',
                           email: 'mike4@turing.com',
                           password: 'ilikefood',
                           role: 0)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80_203)
      @brian = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80_210)

      @handlebars = @meg.items.create(name: "Handle Bars", description: "Grip it", price: 50, image: "https://cdn.shopify.com/s/files/1/2191/9809/products/bullhorn2__95733.1479507031.1280.960_1024x1024.jpg?v=1501527872", inventory: 243)
      @chain = @meg.items.create(name: "Chain", description: "Strong", price: 25, image: "https://dks.scene7.com/is/image/GolfGalaxy/19SCWUBMX12X18CHRTAM?qlt=70&wid=600&fmt=pjpeg", inventory: 232)
      @pedal = @meg.items.create(name: "Pedal", description: "Step on it", price: 10, image: "https://keyassets.timeincuk.net/inspirewp/live/wp-content/uploads/sites/11/2020/06/meow.jpg", inventory: 374)
      @reflector = @meg.items.create(name: "Reflector", description: "They'll see you", price: 5, image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcStDVPL-iMrlZHu5mai-EXeyDH-wH2r9nBeFw&usqp=CAU", inventory: 324)
      @seat = @meg.items.create(name: "Seat", description: "Soft", price: 123, image: "https://i5.walmartimages.com/asr/597375a9-fb8f-4a47-a4a2-28201888754a_1.3ebe254d3fea4ff52d5578eda9e44f77.jpeg", inventory: 217)
      @tire = @meg.items.create(name: 'Gatorskins', description: "They'll never pop!", price: 100, image: 'https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588', inventory: 12)
      @chain = @meg.items.create(name: "Chain", description: "It'll never break!", price: 50, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 5)
      @pull_toy = @brian.items.create(name: 'Pull Toy', description: 'Great pull toy!', price: 10, image: 'http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg', inventory: 32)

      @order_1 = @user.orders.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17_033)

      @io_1 = @order_1.item_orders.create!(item: @tire, price: @tire.price, quantity: 2)
      @io_2 = @order_1.item_orders.create!(item: @pull_toy, price: @pull_toy.price, quantity: 3)
    end

    it '#status_update ' do
      expect(@order_1.status).to eq('pending')

      @io_1.fulfill
      @io_2.fulfill


      expect(@order_1.status).to eq('packaged')

      @io_1.unfulfill

      expect(@order_1.status).to eq('pending')

      @io_1.fulfill

      expect(@order_1.status).to eq('packaged')
    end

    it 'grandtotal' do
      expect(@order_1.grandtotal).to eq(230)
    end

    it '#item_count' do
      expect(@order_1.item_count).to eq(5)
    end

    it "#date_created" do
      expect(@order_1.date_created).to eq(@order_1.created_at.strftime('%m/%d/%Y'))
    end

    it "#date_updated" do
      expect(@order_1.date_updated).to eq(@order_1.updated_at.strftime('%m/%d/%Y'))
    end

    it 'can be cancelled' do
      @order_1.cancel_order
      expect(@order_1.status).to eq('cancelled')
    end

    it 'items in order can be unfulfilled' do
      @order_1.unfulfill_items
      expect(@order_1.item_orders.pluck(:status)).to all(eq('unfulfilled'))
    end

    it 'returns item_orders for a specific merchant' do
      expect(@order_1.merchant_items(@meg.id)).to eq([@tire])
    end

    it "returns total sales for a merchant's order" do
      expect(@order_1.total_sales(@meg.id)).to eq(200.0)
    end

    it '#merchant_item_count' do
      expect(@order_1.merchant_item_count(@meg.id)).to eq(2)
      expect(@order_1.merchant_item_count(@brian.id)).to eq(3)
    end

    it '#add_item' do
      expect(@order_1.item_orders.count).to eq(2)

      io_3 = @order_1.add_item(@chain, 2)
      expect(@order_1.item_orders.count).to eq(3)
      expect(io_3.quantity).to eq(2)
    end

    it '#total_discounts' do
      ten_for_five = @meg.discounts.create(quantity: 10, percentage: 5)
      fifteen_for_twenty = @meg.discounts.create(quantity: 15, percentage: 20)
      io_3 = @order_1.item_orders.create!(item: @pedal, price: @pedal.price, quantity: 11)
      io_4 = @order_1.item_orders.create!(item: @reflector, price: @reflector.price, quantity: 18)

      expect(@io_1.apply_discount).to eq(nil)
      expect(@io_2.apply_discount).to eq(nil)
      expect(io_3.apply_discount).to eq(5.5)
      expect(io_4.apply_discount).to eq(18.0)

      expect(@order_1.total_discounts).to eq(23.5)
    end

    it '#total_after_discount' do
      ten_for_five = @meg.discounts.create(quantity: 10, percentage: 5)
      fifteen_for_twenty = @meg.discounts.create(quantity: 15, percentage: 20)
      io_3 = @order_1.item_orders.create!(item: @pedal, price: @pedal.price, quantity: 11)
      io_4 = @order_1.item_orders.create!(item: @reflector, price: @reflector.price, quantity: 18)

      expect(@order_1.grandtotal).to eq(430.0)
      expect(@order_1.total_discounts).to eq(23.5)

      expect(@order_1.total_after_discount).to eq(406.5)
    end
  end
end
