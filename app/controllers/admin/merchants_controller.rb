class Admin::MerchantsController < ApplicationController
  before_action :require_admin

  def index
    @merchants = Merchant.all
  end

  def show
    @merchant = Merchant.find(params[:id])
  end

private
  def require_admin
    render file: "/public/404" unless current_admin?
  end
end
