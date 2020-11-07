class Merchant::DiscountsController < ApplicationController
  before_action :require_merchant

  def index
  end

  def new
    user = current_user
    @discount = user.merchant.discounts.new
  end

private
  def require_merchant
    render file: "/public/404" unless current_merchant?
  end
end