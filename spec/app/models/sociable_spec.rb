require 'spec_helper'

describe Sociable do

  before(:all) do
    class TempClass
      include Sociable
    end
  end
  
  context "class methods" do
    it "should have method node_in_social_graph_with " do
      TempClass.singleton_methods.include?(:node_in_social_graph_with).should be_true
    end
    it "should have method load_node" do
      TempClass.singleton_methods.include?(:load_node).should be_true
    end
  end

  context "instance methods" do
    it "should have method friends_with" do
      TempClass.instance_methods.include?(:friends_with).should be_true
    end 
  end

end
