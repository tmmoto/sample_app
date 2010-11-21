require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'show'" do

    before(:each) do
      #@user = User.create!({:name => 'Tibor', :email => 't@tt.com', :password => 'foobar', :password_confirmation => 'foobar'})
      @user = Factory(:user)   # :user is a class that we defined in the factories.rb
    end

    it "should be successful" do
      get :show, :id => @user.id  # Could use @user as well, due the flexibility of rails
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user.id
      assigns(:user).should == @user  # assign method from RSpec will will return the @user symbol in the controller. 
      #So we are testing here if the show action really returning the right object here
    end
    
    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector('title', :content => @user.name ) 
    end
    
    it "should have the user's name" do
      get :show, :id => @user
      response.should have_selector('h1', :content => @user.name ) 
    end
    
    it "should have a profile image" do
      get :show, :id => @user 
      response.should have_selector('h1>img', :class => "gravatar")  # Searching in <H1><img> tags for the gravar class 
    end
    
    it "should have the right URL" do
      get :show, :id => @user
      response.should have_selector('td>a', :content => user_path(@user),
                                            :href => user_path(@user)) 
    end
  end   

  describe "GET 'new'" do
    
    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector('title', :content => "Sign Up")
    end

  end

  describe "POST 'create'" do

    describe "failure" do    
      
      before(:each) do
        @attr = { :name => "", :email => "", :password => "", :password_confirmation => "" }  # Invalid user data
      end
    
      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector('title', :content => "Sign Up")  
      end
      
      
      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
      
      it "should not create a user" do  # Lambda block
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
        
      end  
    end
    
    describe "success" do
      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com", :password => "foobar", :password_confirmation => "foobar" }  # Invalid user data
      end
            
     it "should create a user" do
       lambda do 
         post :create, :user => @attr
       end.should change(User, :count).by(1) 
     end
     
     
     it "should redirect to the user show page" do
       post :create, :user => @attr
       response.should redirect_to(user_path(assigns(:user)))  #assigns(:user)  pulls teh @user object from the current action
     end
     
     it "should have a welcom messsage" do
       post :create, :user => @attr
       flash[:success].should =~ /welcome to the sample app/i 
     end
     
     it "should save user to the databae" 
     
     it "should show the saved users information"
       
    
      
    end    
  end
end
