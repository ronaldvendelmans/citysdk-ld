Sequel.migration do

	up do

    $stderr.puts("Creating tables...")
    
    
    create_table  :endpoints do  
      primary_key :id
      String      :code, :unique => true
      String      :api
      String      :name, nil => false
      String      :description
      String      :email
    end
    
    create_table  :layers do      
      primary_key :id
      integer     :endpoint_id
      String      :name
      String      :description
      String      :category
      String      :sample_url
    end

    run <<-SQL
      SELECT AddGeometryColumn('layers', 'bbox', 4326, 'GEOMETRY', 2 );
      ALTER TABLE layers ADD CONSTRAINT constraint_bbox_4326 CHECK (ST_SRID(bbox) = 4326);
      CREATE INDEX ON layers USING gist(bbox);
      CREATE INDEX ON layers USING btree(category);
    SQL
	
	end
	
	down do
		drop_table(:layers)
		drop_table(:endpoints)
	end
end
