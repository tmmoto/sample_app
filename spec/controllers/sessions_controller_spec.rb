require 'spec_helper'

describe SessionsController do
  render_views
   
  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
    
    it "should have the right title" do
      get :new
      response.should have_selector('title', :content => "Sign in")
    end
  end

  describe "POST 'create'" do

    describe "failure" do
      before(:each) do
        @attr = { :email => "", :password => "" }
      end
      
      it  "should re-render the new page" do
        post :create, :session => @attr
        response.should render_template('new')
      end
      
      it "should have the right title" do
        post :create, :session => @attr
        response.should have_selector('title', :content => "Sign in")
      end
                
      # it "should not create a new session" do # TM not sure if we need this, but perhaps it would make sense to test 
        
      
      it "should have an error message" do
        post :create, :session => @attr  
        flash.now[:error].should =~ /invalid/i
      end 
    end  

    describe "success" do
      before(:each) do
        @user = Factory(:user)
        @attr = { :email => @user.email, :password => @user.password }
      end
      
      it "should sign the user in" do
        post :create, :session => @attr
        controller.current_user == @user # Inside  a test, you can access the controller that is being tested by controller.attribute/method
        controller.should be_signed_in    # be_signed_in corresponds to the signed_in?  method, so we need to create one
      end
      
      it "should redirect to the user show page" do
        post  :create, :session => @attr
        response.should redirect_to(user_path(@user))
      end
    end  
    
    describe "DELETE 'destroy" do
      
      it "should sign a user out" do
        test_sign_in(Factory(:user))  # will define this test method in spec_helper
        #controller.current_user=Factory(:user)  #could use these sing ins too.
        #controller.sign_in(Factory(:user))
        delete :destroy
        controller.should_not be_signed_in
        response.should redirect_to(root_path)
      end
    end
  end
end
