require 'spec_helper'

describe User do

  context "create" do
    before(:each) do
      @neo_rest_client = Neography::Rest.new
    end

    after(:each) do
     @neo_rest_client.delete_node(@user_node)
    end
    
    it "should create a node and its index in neo4j database" do
      user = User.create({:first_name => "sandeep", :last_name => "jagtap", :unique_identifier => "sanjag" })
      user_node_data  = @neo_rest_client.find_node_index(User::USER_INDEX, "unique_identifier", user.unique_identifier)
      user_node_data.should_not be_nil
      @user_node = Neography::Node.load(user_node_data)

      @user_node.should_not be_nil
    end
  end

  context "load node" do
    before(:each) do
      @neo_rest_client = Neography::Rest.new
    end

    after(:each) do
      @neo_rest_client.delete_node(@user_node)
    end

    it "should load node from neo4j" do
      user = User.create({:first_name => "sandeep", :last_name => "jagtap", :unique_identifier => "sanjag" })
      @user_node = User.load_node(user)

      @user_node.unique_identifier.should == "sanjag"
      
    end
    
  end
  
  context "friends" do
     before(:each) do
      @neo_rest_client = Neography::Rest.new
    end

    after(:each) do
      @neo_rest_client.delete_relationship(@rel1)
      @neo_rest_client.delete_relationship(@rel2)
      @neo_rest_client.delete_node(@user_node_1)
      @neo_rest_client.delete_node(@user_node_2)
    end
    
    it "should make users friends with each other" do
      sandeep = User.create({:first_name => "sandeep", :last_name => "jagtap", :unique_identifier => "sanjag" })
      ranjeet  = User.create({:first_name => "ranjeet", :last_name => "jagtap", :unique_identifier => "ranjag" })

      sandeep.friends_with(ranjeet)

      @user_node_1 = User.load_node(sandeep)
      @user_node_2 = User.load_node(ranjeet)

      
      @rel1 = @user_node_1.rels(Sociable::Relationship::FRIENDS).first
      @rel1.start_node.unique_identifier.should == "sanjag"
      @rel1.end_node.unique_identifier.should == "ranjag"

      @rel2 = @user_node_2.rels(Sociable::Relationship::FRIENDS).first
      @rel2.start_node.unique_identifier.should == "ranjag"
      @rel2.end_node.unique_identifier.should == "sanjag"
     
    end
  end
  
  
end
