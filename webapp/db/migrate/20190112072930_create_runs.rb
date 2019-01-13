Sequel.migration do
  change do

    create_table(:runs) do
      primary_key :id
      Integer :runner_id, :null=>false
      String :bussiness_id, :null=>false
      DateTime :datetime, :null=>false
      Integer :order_cap, :null=> false
      Integer :status, :null=>false
      Integer :delivery_method, :null=>false
      Text :pickup_addr, :null=>false
      Text :notes
    end

  end
end
