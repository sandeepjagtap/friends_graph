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

   def create_node_in_neo4j
     params = {}
     self.class.class_variable_get("@@properties").each do |property|
       params[property] = self.send(property)
     end
     node = Neography::Node.create(params)
     index_field_name = self.class.class_variable_get("@@index_field_name")
     GraphClient.instance.add_node_to_index(self.class.class_variable_get("@@index_name"), index_field_name, self.send(index_field_name), node)
   end
  
  module ClassMethods

    def node_in_social_graph_with(index_field_name, properties)
      index_name =  "#{self.name.downcase.pluralize}-index"
      GraphClient.instance.create_node_index(index_name)  unless GraphClient.instance.list_node_indexes.try(:include?, index_name)

      self.class_variable_set("@@index_name", index_name)
      self.class_variable_set("@@properties", properties)
      self.class_variable_set("@@index_field_name", index_field_name)
      
      self.instance_eval do
        after_create :create_node_in_neo4j
      end

      def load_node(model)
        index_field_name =  self.class_variable_get("@@index_field_name")
        Neography::Node.load(GraphClient.instance.find_node_index(self.class_variable_get("@@index_name"), index_field_name, model.send(index_field_name)))
      end
          
    end
  end
  
end


class GraphClient
  include Singleton
  extend Forwardable
  
  def_delegators :@neo_driver, :create_node_index, :list_node_indexes, :add_node_to_index, :find_node_index
  
  def initialize()
     @neo_driver = Neography::Rest.new
  end
  
end
