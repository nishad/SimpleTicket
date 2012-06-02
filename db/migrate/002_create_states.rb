class CreateStates < ActiveRecord::Migration
  def self.up
    create_table :states do |t|
      t.column "short_name",  :string, :limit => 2
      t.column "long_name",   :string, :limit => 20
    end
    
    [
        [ "Alabama", "AL" ],
        [ "Alaska", "AK" ],
        [ "Arizona", "AZ" ],
        [ "Arkansas", "AR" ],
        [ "California", "CA" ],
        [ "Colorado", "CO" ],
        [ "Connecticut", "CT" ],
        [ "Delaware", "DE" ],
        [ "Florida", "FL" ],
        [ "Georgia", "GA" ],
        [ "Hawaii", "HI" ],
        [ "Idaho", "ID" ],
        [ "Illinois", "IL" ],
        [ "Indiana", "IN" ],
        [ "Iowa", "IA" ],
        [ "Kansas", "KS" ],
        [ "Kentucky", "KY" ],
        [ "Louisiana", "LA" ],
        [ "Maine", "ME" ],
        [ "Maryland", "MD" ],
        [ "Massachusetts", "MA" ],
        [ "Michigan", "MI" ],
        [ "Minnesota", "MN" ],
        [ "Mississippi", "MS" ],
        [ "Missouri", "MO" ],
        [ "Montana", "MT" ],
        [ "Nebraska", "NE" ],
        [ "Nevada", "NV" ],
        [ "New Hampshire", "NH" ],
        [ "New Jersey", "NJ" ],
        [ "New Mexico", "NM" ],
        [ "New York", "NY" ],
        [ "North Carolina", "NC" ],
        [ "North Dakota", "ND" ],
        [ "Ohio", "OH" ],
        [ "Oklahoma", "OK" ],
        [ "Oregon", "OR" ],
        [ "Pennsylvania", "PA" ],
        [ "Rhode Island", "RI" ],
        [ "South Carolina", "SC" ],
        [ "South Dakota", "SD" ],
        [ "Tennessee", "TN" ],
        [ "Texas", "TX" ],
        [ "Utah", "UT" ],
        [ "Vermont", "VT" ],
        [ "Virginia", "VA" ],
        [ "Washington", "WA" ],
        [ "West Virginia", "WV" ],
        [ "Wisconsin", "WI" ],
        [ "Wyoming", "WY" ]
      ].each do |state|
      State.create( :short_name => state[1], :long_name => state[0])
    end
  end

  def self.down
    drop_table :states
  end
end
