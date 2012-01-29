module Sociable
    
  module Relationship
    FRIENDS = "friends"
  end
   
  def self.included(klass)
    klass.extend(Sociable::ClassMethods)
  end

  def friends_with(model)
    self.class.load_node(self).both(Sociable::Relationship::FRIENDS) << self.class.load_node(model)
  end

  def suggested_friends
    node_id = self.class.load_node(self).neo_id.to_i
    GraphRestClient.instance.execute_query("START me = node({node_id})
                                            MATCH (me)-[:friends]->(friend)-[:friends]->(result)
                                            RETURN result.first_name", {:node_id => node_id })["data"]
  end

  private
  def create_node_in_neo4j
    params = {}
    self.class.class_variable_get("@@properties").each do |property|
      params[property] = self.send(property)
    end
    node = Neography::Node.create(params)
    index_field_name = self.class.class_variable_get("@@index_field_name")
    GraphRestClient.instance.add_node_to_index(self.class.class_variable_get("@@index_name"), index_field_name, self.send(index_field_name), node)
  end
  
  module ClassMethods

    def node_in_social_graph_with(index_field_name, properties)
      index_name =  "#{self.name.downcase.pluralize}-index"
      GraphRestClient.instance.create_node_index(index_name)  unless GraphRestClient.instance.list_node_indexes.try(:include?, index_name)

      self.class_variable_set("@@index_name", index_name)
      self.class_variable_set("@@properties", properties)
      self.class_variable_set("@@index_field_name", index_field_name)
      
      self.instance_eval do
        after_create :create_node_in_neo4j
      end

      def load_node(model)
        index_field_name =  self.class_variable_get("@@index_field_name")
        Neography::Node.load(GraphRestClient.instance.find_node_index(self.class_variable_get("@@index_name"), index_field_name, model.send(index_field_name)))
      end
          
    end
  end
  
end


class GraphRestClient
  include Singleton
  extend Forwardable
  
  def_delegators :@neo_driver, :create_node_index, :list_node_indexes, :add_node_to_index, :find_node_index, :execute_query
  
  def initialize()
     @neo_driver = Neography::Rest.new
  end
  
end
