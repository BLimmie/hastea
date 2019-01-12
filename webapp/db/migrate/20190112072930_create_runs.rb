Sequel.migration do
  change do

    create_table(:runs) do
      primary_key :id
      Integer :runner_id, :null=>false
      Integer :bussiness_id, :null=>false
      DateTime :datetime, :null=>false
      Integer :order_cap, :null=> false
      Integer :status, :null=>false
      Integer :delivery_method, :null=>false
      Integer :pickup_addr
      Text :notes
    end

  end
end
