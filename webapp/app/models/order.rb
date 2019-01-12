class Order < Sequel::Model
  ORDER_STATUS = {
    1 => "Active",
    0 => "InActive"
    }
end
