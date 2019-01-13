Sequel.migration do
  change do

    create_table :comments do
      primary_key :id
      Integer :run_id
      Integer :author_id
      Text :content
    end

  end
end
