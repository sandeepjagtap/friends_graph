class User < ActiveRecord::Base

  include Sociable

  node_in_graph_with(self,[])

  USER_INDEX = "users-index"
  @@neo_driver ||= Neography::Rest.new
  
  after_create :create_user_node_in_neo4j

  def friends_with(user)
    User.load_node(self).both(Sociable::Relationship::FRIENDS) << User.load_node(user)
  end
  
  def create_user_node_in_neo4j
    node = Neography::Node.create({:first_name => first_name,:last_name => last_name, :unique_identifier => unique_identifier })
    @@neo_driver.add_node_to_index(USER_INDEX,"unique_identifier",unique_identifier,node)
  end
 
  def self.load_node(user)
    Neography::Node.load(@@neo_driver.find_node_index(USER_INDEX, "unique_identifier", user.unique_identifier))
  end
  
end
