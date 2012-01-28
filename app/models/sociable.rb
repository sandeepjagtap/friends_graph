module Sociable

   module Relationship
    FRIENDS = "friends"
   end
   
  def self.included(klass)
    klass.extend(Sociable::ClassMethods)
  end
  
  module ClassMethods
    def node_in_graph_with(klass, properties)
      index_name = "#{klass.name.downcase.pluralize}-index"
      GraphClient.instance.create_node_index(index_name)  unless GraphClient.instance.list_node_indexes.try(:include?, index_name)
      @@properties ||= [] << properties
    end
  end
end


class GraphClient
  include Singleton
  extend Forwardable
  
  def_delegators :@neo_driver, :create_node_index, :list_node_indexes
  
  def initialize()
     @neo_driver = Neography::Rest.new
  end
  
end
