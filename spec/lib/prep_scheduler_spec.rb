require 'spec_helper'
require_relative '../../lib/prep_scheduler'

RSpec.describe PrepScheduler do
  describe "schedule" do
    let(:items) do
      [
        { item_id: 1, qty: 2 },
        { item_id: 2, qty: 1 },
        { item_id: 3, qty: 1 }
      ]
    end

    it "returns scheduled items with correct values and order" do
      schedule = PrepScheduler.new(items).schedule
      expect(schedule).to eq([180, 135])
    end

  end
end