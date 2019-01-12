class Run < Sequel::Model
  RUN_STATUS = {
    0 = "Pending"
    1 = "Ordered"
    2 = "In transit"
    3 = "Out for Delivery"
    4 = "Avaliable for Pickup"
    }
end
