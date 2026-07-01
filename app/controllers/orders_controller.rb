class OrdersController < ApplicationController
  require 'prep_scheduler'

  def create
    items = order_params[:items]
    
    return render json: { error: "qty must be a positive integer"}, status: :bad_request if items.any? { |item| item[:qty].to_i < 1 }
    return render json: { error: "item_id not found"}, status: :bad_request if items.any? { |item| PrepScheduler::MENU[item[:item_id].to_i].nil? }

    subtotal = items.sum { |item| PrepScheduler::MENU[item[:item_id].to_i][:price_cents] * item[:qty].to_i }
    discount = (subtotal >= 2000 ? subtotal * 0.1 : 0).round
    total = subtotal - discount
    prep_schedule = PrepScheduler.new(items).schedule

    return render json: { 
      subtotal_cents: subtotal,
      discount_cents: discount,
      total_cents: total,
      estimated_prep_seconds: prep_schedule[0],
      prep_schedule: [
        [1, prep_schedule[0]],
        [2, prep_schedule[1]]
      ]
    }
  end

  private

  def order_params
    params.require(:items)
    params.permit(items: [:item_id, :qty])
  end
end
