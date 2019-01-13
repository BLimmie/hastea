class Run < Sequel::Model
  RUN_STATUS = {
    0 => "Pending",
    1 => "In transit",
    2 => "Done"
    }
end
