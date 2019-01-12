Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :phone_number, :null => false, :unique => true
      String :email, :null => false, :unique => true
      Integer :is_verified, :null => false
      String :first_name, :null => false
      String :last_name, :null => false
      Integer :activation_code, :null=>false
      Integer :credits, :null => false
      Integer :rating_score, :null => false
      Integer :rating_count, :null => false
      String :password, :null => false
      String :salt, :null => false
    end

  end
end
