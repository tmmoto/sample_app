require 'spec_helper'

describe UsersController do
  render_views
  
  describe "GET 'index'" do
    
    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
      end
    end
    
    describe "for signed in users" do
      
      before(:each) do
        @user = test_sign_in(Factory(:user))  # The sign in method will sign in and return the signed in user
        
        Factory(:user, :email => "user2@example.com")
        Factory(:user, :email => "user3@example.com")
        Factory(:user, :email => "user4@example.com")
        
        @someusers = [@user]
        
        30.times do # |i| with could just interpolate here
          @someusers << Factory(:user, :email => Factory.next(:email))
        end
      end
      
      it "should be successful" do
        get :index
        response.should be_success
      end
      
      it "should the rigt title" do
        get :index
        response.should have_selector('title', :content => "All users" )
      end
      
      it "should have an element for each user" do
        get :index
        User.paginate(:page =>1 ).each do |user|
          response.should have_selector('li', :content => user.name )
        end  
      end
      
      it "should have an element for each user --alternative test" do
        get :index
        @someusers[0..2].each do |user|
          response.should have_selector('li', :content => user.name, )
        end
      end 
      
      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector('span.disabled', :content => 'Previous')
        response.should have_selector('a', :href => "/users?page=2", :content => '2')
        response.should have_selector('a', :href => "/users?page=2", :content => 'Next')
      end
      
      it "should have a delete links for admins" do
        @user.toggle!(:admin)  #making @user and admin
        other_user = User.all.second
        get :index
        response.should have_selector('a', :href => user_path(other_user),
                                            :content => 'delete')
      end
      
      it "should not have a delete link for non-admins" do  #TM testing this
        other_user = User.all.second
        get :index
        response.should_not have_selector('a', :href => user_path(other_user),
                                            :content => 'delete')     
      end
    end
  end

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
      #So we are testing if the show action really returning the right object here
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
    
    it "should show the user's microposts" do
      mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
      mp2 = Factory(:micropost, :user => @user, :content => "Foo barz2")
      get :show, :id => @user
      response.should have_selector('span.content', :content => mp1.content)
      response.should have_selector('span.content', :content => mp2.content)
    end
    

    
    it "should paginate microposts" do
      31.times { Factory(:micropost, :user => @user, :content => "foo") }
      get :show, :id => @user
      response.should have_selector("div.pagination")
    end
    
    it "should display the micropost count" do
      10.times { Factory(:micropost, :user => @user, :content => "foo") }
      get :show, :id => @user
      response.should have_selector("td.sidebar", :content => @user.microposts.count.to_s)      
    end    
  end   

  describe "GET 'new'" do
    
    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector('title', :content => "Sign up")
    end

  end

  describe "POST 'create'" do

    describe "failure" do    
      
      before(:each) do
        @attr = { :name => "", :email => "", :password => "", :password_confirmation => "" }  # Invalid user data
      end
    
      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector('title', :content => "Sign up")  
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
        @attr = { :name => "New User", :email => "user@2example.com", :password => "foobar", :password_confirmation => "foobar" }  # Invalid user data
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

      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end    
  end
  
  describe "GET 'edit'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)  
    end
    
    it "should be successful" do
      get :edit, :id => @user
      response.should be_success 
    end
    
    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector('title', :content => "Edit user")
    end
    
    it "should have a linke to change the Gravatar" do
      get :edit, :id => @user
      response.should have_selector('a', :href => 'http://gravatar.com/emails',
                                          :content => 'change') 
    end
  end
  
  describe "PUT 'update'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    
    describe "failure" do
      
      before(:each) do 
        @attr = { :name => "", :email => "", :password => "", :password_confirmation => "" }  # Invalid user data
      end
      
      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end
      
      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector('title', :content => "Edit user")
      end
    end
    
    describe "succes" do
      
      before(:each) do
        @attr = { :name =>"New Name", :email => "t6@2example.com", :password => "foobarx", :password_confirmation=> "foobarx" }
      end
      
      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        user = assigns(:user)   # We are getting the user local variable from the @user contained in the controller. ? 
                                # Why don't we just compare with @attr
        @user.reload #After the update, we are reloading the save data into @user
        @user.name.should == user.name  
        @user.email.should == user.email
        @user.encrypted_password == user.encrypted_password
      end
      
      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/i
      end
    end
  end
  
  describe "authentication of edit/update actions" do
    
    before(:each) do
      @user = Factory(:user)
    end
    # Notice that we don't sign in here before
    
    describe "for non-signed in users" do
      
      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to signin_path
        flash[:notice].should =~ /sign in/i
      end

      it "should deny access to 'update'" do
        put :edit, :id => @user, :user => {}
        response.should redirect_to signin_path
      end
    end
    
    describe "for signed in user" do
      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end
      
      it "should require matching users for 'edit" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
      
      it "should require matching users for 'update" do
        get :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
      
    end
  end
  
  describe "DELETE 'destroy'" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "as a non-singned-in user" do
      it "should deny access" do
        delete :destroy, :id => @user 
        response.should redirect_to(signin_path)   
      end  
    end
    
    describe "as non-admin user" do
      it "should protect the action" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)  #denying access by doing this, just like in other actions
      end
    end
    
    describe "as an admin user" do
      before(:each) do
        @admin = Factory(:user, :email => "admin@example.com", :admin => "true")  # We can set admin=true as Factory bypasses the attr_accesible notion
        test_sign_in(@admin)
      end
      
      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1) 
      end
      
      it "should redirect to the users page (index)" do
        delete :destroy, :id => @user
        flash[:success].should =~ /destroyed/i
        response.should redirect_to(users_path)
      end
      
      it "should not be able to destroy itself" do
        lambda do
          delete :destroy, :id => @admin
        end.should_not change(User, :count)     
      end
    end

  end
end
