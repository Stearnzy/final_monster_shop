class Merchant::DiscountsController < ApplicationController
  before_action :require_merchant

  def index
  end

  def new
    user = current_user
    @discount = user.merchant.discounts.new
  end

  def create
    user = current_user
    @discount = user.merchant.discounts.new(discount_params)
    if !params[:discount][:percentage].empty? && !params[:discount][:quantity].empty?
      begin
          @discount.save!
          flash[:success] = "Discount created successfully!"
          redirect_to '/merchant/discounts'
      rescue ActiveRecord::RecordInvalid => e
        create_error_response(e)
        render :new
      end
    else
      flash[:error] = "Fields cannot be empty"
      render :new
    end
  end

private
  def require_merchant
    render file: "/public/404" unless current_merchant?
  end

  def discount_params
    params.require(:discount).permit(:quantity, :percentage)
  end

  def create_error_response(error)
      flash[:error] = error.message.delete_prefix('Validation failed: ')
  end

  # def check_empty
  #   if params[:discount][:percentage].empty? || params[:discount][:quantity].empty?
  #     flash[:error] = "Fields cannot be empty"
  #     render :new
  #   end
  # end
end