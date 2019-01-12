Sequel.migration do
  change do

    create_table :orders do
      primary_key :id
      Integer :run_id
      Integer :user_id
      Text :order_desc
      Integer :status
      Integer :cost
    end

  end
end
