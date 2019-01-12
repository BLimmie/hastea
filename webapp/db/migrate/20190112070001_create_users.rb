Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      Integer :phone_number, :null => false, :unique => true
      String :email, :null => false, :unique => true
      Integer :is_verified, :null => false
      String :name, :null => false
      Integer :credits, :null => false
      Integer :rating_score, :null => false
      Integer :rating_count, :null => false
    end

  end
end
