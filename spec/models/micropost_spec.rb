require 'spec_helper'

describe Micropost do
  
  before(:each) do
    @user = Factory(:user)
    @attr = { :contet => "foo bar" }
  end
  
  it "should create a new instance with valid attributes" do
    @user.microposts.create!(@attr)
  end
  # We are doing this, just as in the user_spec to get started with some basic test.
  # If something goes wrong, ! should rais an exception -- lets test this
  
  
  describe "user asscociations" do
    
    before(:each) do
      @micropost = @user.microposts.create(@attr)
    end
    
    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end
  
    it "should have the right user associated" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
  
  end
  
  

end
