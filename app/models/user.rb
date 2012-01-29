class User < ActiveRecord::Base

  include Sociable
  node_in_social_graph_with(:unique_identifier, [:first_name, :last_name, :unique_identifier])
  
end
