require 'rails_helper'

RSpec.describe "Orders", type: :request do
  describe "POST /orders" do
    let(:valid_items) do
      {
        items: [
          { item_id: 1, qty: 2 },
          { item_id: 2, qty: 1 },
          { item_id: 3, qty: 1 }
        ]
      }
    end

    it "returns a successful order with correct totals and prep schedule" do
      post "/orders", params: valid_items, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json["subtotal_cents"]).to eq(2696)   # 899*2 + 399 + 499
      expect(json["discount_cents"]).to eq(270)    # 10% of 2696, rounded
      expect(json["total_cents"]).to eq(2426)
      expect(json["estimated_prep_seconds"]).to be_a(Integer)

      # prep_schedule is sorted descending by prep seconds
      schedule = json["prep_schedule"]
      expect(schedule.length).to eq(2)
      expect(schedule.first[1]).to be >= schedule.last[1]
    end

    it "returns 400 when items is missing" do
      post "/orders", params: {}, as: :json
      expect(response).to have_http_status(:bad_request)
    end

    it "returns 400 when qty is not a positive integer" do
      post "/orders", params: { items: [{ item_id: 1, qty: 0 }] }, as: :json
      expect(response).to have_http_status(:bad_request)
    end

    it "returns 400 when item_id does not exist" do
      post "/orders", params: { items: [{ item_id: 99, qty: 1 }] }, as: :json
      expect(response).to have_http_status(:bad_request)
    end
  end
end
