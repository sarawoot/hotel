class SummaryTransaction < ActiveRecord::Base
  attr_accessible :amount, :seq, :payment, :product_place, :room_list_id, :shift_name, :username, :vol
end
