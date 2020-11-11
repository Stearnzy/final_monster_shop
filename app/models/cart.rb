class Cart
  attr_reader :contents

  def initialize(contents)
    @contents = contents
  end

  def [](key)
    @contents[key]
  end

  def []=(key, value)
    @contents[key] = value
  end

  def add_item(item)
    @contents[item] = 0 if !@contents[item]
    @contents[item] += 1
  end

  def total_items
    @contents.values.sum
  end

  def items
    item_quantity = {}
    @contents.each do |item_id,quantity|
      item_quantity[Item.find(item_id)] = quantity
    end
    item_quantity
  end

  def subtotal(item)
    item.price * @contents[item.id.to_s]
  end

  def total
    @contents.sum do |item_id,quantity|
      Item.find(item_id).price * quantity
    end
  end

  def discount_subtotal
    total_discount = 0
    @contents.each do |item_id, quantity|
      item = Item.find(item_id)
      if !item.find_applicable_discount(quantity).nil?
        total_discount += item.calculate_discount(quantity)
      end
    end
    total_discount
  end

  def post_discount_total
    total - discount_subtotal
  end
end
