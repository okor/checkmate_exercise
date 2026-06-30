class PrepScheduler
  MENU = {
    1 => { name: "Cheeseburger", price_cents: 899, prep_seconds: 90 },
    2 => { name: "Fries",        price_cents: 399, prep_seconds: 60 },
    3 => { name: "Milkshake",    price_cents: 499, prep_seconds: 75 },
    4 => { name: "Salad",        price_cents: 699, prep_seconds: 45 },
    5 => { name: "Nuggets",      price_cents: 599, prep_seconds: 80 },
  }.freeze

  def initialize(items)
    @items = items
  end

  def schedule
    prep_schedule = [0, 0]

    @items.each do |item|
      prep_schedule = prep_schedule.sort
      prep_schedule[0] += MENU[item[:item_id].to_i][:prep_seconds] * item[:qty].to_i
    end

    prep_schedule = prep_schedule.sort.reverse
  end
end