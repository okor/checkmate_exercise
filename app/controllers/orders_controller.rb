class OrdersController < ApplicationController
  MENU = {
    1 => { name: "Cheeseburger", price_cents: 899, prep_seconds: 90 },
    2 => { name: "Fries",        price_cents: 399, prep_seconds: 60 },
    3 => { name: "Milkshake",    price_cents: 499, prep_seconds: 75 },
    4 => { name: "Salad",        price_cents: 699, prep_seconds: 45 },
    5 => { name: "Nuggets",      price_cents: 599, prep_seconds: 80 },
  }.freeze

  def create
    items = order_params[:items]
    
    return render json: { error: "items cannot be blank" }, status: :bad_request if items.blank?
    return render json: { error: "qty must be a positive integer"}, status: :bad_request if items.any? { |item| item[:qty].to_i < 1 }
    return render json: { error: "item_id must not be blank"}, status: :bad_request if items.any? { |item| item[:item_id].blank? }
    return render json: { error: "item_id not found"}, status: :bad_request if items.any? { |item| item[:item_id].to_i > 5 }

    subtotal = items.sum { |item| MENU[item[:item_id].to_i][:price_cents] * item[:qty].to_i }
    discount = (subtotal > 2000 ? subtotal * 0.1 : 0).round
    total = subtotal - discount
    estimated_prep_seconds = items.sum { |item| MENU[item[:item_id].to_i][:prep_seconds]  * item[:qty].to_i }

    prep_schedule = [0, 0]

    items.each do |item|
      qty = item[:qty].to_i
      qty.times do
        prep_schedule = prep_schedule.sort
        prep_schedule[0] += MENU[item[:item_id].to_i][:prep_seconds]
      end
    end

    prep_schedule = prep_schedule.sort.reverse

    return render json: { 
      subtotal_cents: subtotal,
      discount_cents: discount,
      total_cents: total,
      estimated_prep_seconds: estimated_prep_seconds,
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
