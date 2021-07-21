class TrialBalance < ActiveRecord::Base
  attr_accessible :credit, :debit, :product_name, :products_id, :seq, :username
end
