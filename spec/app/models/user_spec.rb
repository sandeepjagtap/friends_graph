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
      user_node_data  = @neo_rest_client.find_node_index("users-index", "unique_identifier", user.unique_identifier)
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
      [@rel1, @rel2].each do |rel|
         @neo_rest_client.delete_relationship(rel)
      end
      [@user_node_1, @user_node_2].each do |node|
        @neo_rest_client.delete_node(node)
      end
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

  context "suggested friends" do
    before(:each) do
      @neo_rest_client = Neography::Rest.new
    end

    after(:each) do
        
      [@sandeep,@ranjeet,@prasanna,@harun,@aman].each do |user|
        User.load_node(user).rels(Sociable::Relationship::FRIENDS).each do |rel| 
          @neo_rest_client.delete_relationship(rel)
        end
      end
      
      [@sandeep,@ranjeet,@prasanna,@harun,@aman].each do |user|
        @neo_rest_client.delete_node(User.load_node(user))
      end
      
    end
    
    it "should suggest friends" do
      @sandeep = User.create({:first_name => "sandeep", :last_name => "jagtap", :unique_identifier => "sanjag" })
      @ranjeet  = User.create({:first_name => "ranjeet", :last_name => "jagtap", :unique_identifier => "ranjag" })
      @prasanna = User.create({:first_name => "prasanna", :last_name => "pendse", :unique_identifier => "prapen" })
      @harun = User.create({:first_name => "harun", :last_name => "pathan", :unique_identifier => "harpat" })
      @aman =  User.create({:first_name => "aman", :last_name => "king", :unique_identifier => "amakin" })

      @prasanna.friends_with(@sandeep)
      @sandeep.friends_with(@aman)
      @sandeep.friends_with(@harun)
      @aman.friends_with(@harun)
      @aman.friends_with(@ranjeet)

      actual =  @prasanna.suggested_friends.flatten
      actual.should include "aman"
      actual.should include "harun"
      
    end
  end
  
end
