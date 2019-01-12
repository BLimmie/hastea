Sequel.migration do
  change do
    create_table(:runs) do
      primary_key :id, :type=>"int(11)"
      column :runner_id, "int(11)", :null=>false
      column :bussiness_id, "int(11)", :null=>false
      column :datetime, "datetime", :null=>false
      column :order_cap, "int(11)", :null=>false
      column :status, "int(11)", :null=>false
      column :delivery_method, "int(11)", :null=>false
      column :pickup_addr, "int(11)"
      column :notes, "text"
    end
    
    create_table(:schema_migrations) do
      column :filename, "varchar(255)", :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:users) do
      primary_key :id, :type=>"int(11)"
      column :phone_number, "int(11)", :null=>false
      column :email, "varchar(255)", :null=>false
      column :is_verified, "int(11)", :null=>false
      column :name, "varchar(255)", :null=>false
      column :credits, "int(11)", :null=>false
      column :rating_score, "int(11)", :null=>false
      column :rating_count, "int(11)", :null=>false
      
      index [:email], :name=>:email, :unique=>true
      index [:phone_number], :name=>:phone_number, :unique=>true
    end
  end
end
              Sequel.migration do
                change do
                  self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20190112070001_create_users.rb')"
self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20190112072930_create_runs.rb')"
                end
              end
