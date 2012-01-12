class CreateDefaultTables < ActiveRecord::Migration
  def change
    create_table :parkingramps do |t|
      t.string :name
      t.integer :operator_id
      t.string :category
      t.string :info_status
      t.text :info_pricing
      t.text :info_openinghours
      t.text :info_address
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
    
    
    create_table :parkingplanes do |t|
      t.string :name
      t.integer :parkingramp_id
      t.integer :sorting
      t.integer :lots_total, :default => 0
      t.integer :lots_taken, :default => 0

      t.timestamps
    end
    
    create_table :parkinglots do |t|
      t.integer :parkingplane_id
      t.string :category
      t.boolean :taken, :default => false
      t.integer :x
      t.integer :y

      t.timestamps 
    end
    add_index :parkinglots, [:parkingplane_id, :x,:y], {:unique => true}
    
    create_table :stats do |t|
      t.integer :parkingplane_id
      t.integer :lots_total
      t.integer :lots_taken

      t.timestamps
    end
    
    create_table :concretes do |t|
      t.integer :parkingplane_id
      t.string :category
      t.integer :x
      t.integer :y

      t.timestamps
    end
    add_index :concretes, [:parkingplane_id, :x,:y], {:unique => true}
    
  end
end
