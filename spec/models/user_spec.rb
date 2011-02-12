require 'spec_helper'

describe User do
  
  before(:each) do
    @attr = { :name => "Example User", 
              :email => "user@2example.com", 
              :password => "AsupErPw", 
              :password_confirmation => "AsupErPw",
              }
  end
  
  # We are doing this just to see an error if something goes wrong with the initial  user creation
  it "should create a new instance given a valid attribute" do
    User.create!(@attr)
  end
  
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end  
  
  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end
  
  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid 
  end  

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end
  
  it "should reject invalid email addresses" do
    # Immpossible to thorough here, so this is just sanity check
    addresses = %w[user@foo THE_USERfoo.bar.org first@last@foo.jp]  
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end 
  
  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject email addresses indentical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end  
    
  describe "passwords" do
    before(:each) do
      @user=User.create!(@attr)
    end
    
    it "should have a password attribute" do
      @user.should respond_to(:password)
    end
    
    it "should have a password confirmation attribute" do
      @user.should respond_to(:password_confirmation)
    end  
  end
  
  describe "password validations" do
    it "should require a password" do
      User.new(@attr.merge(:password =>"", :password_confirmation => "")).should_not be_valid
    end
    
    it "should require a mathching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "InvAlid")).should_not be_valid
    end
    
    it "should reject short passwords" do
      short_password = "a" * 5
      attr2 = @attr.merge(:password => short_password, :password_confirmation => short_password )
      User.new(attr2).should_not be_valid
    end
    
    it "should reject long passwords" do
      long_password = "a" * 41
      attr2 = @attr.merge(:password => long_password, :password_confirmation => long_password )
      User.new(attr2).should_not be_valid
    end
  end
  
  describe "password encryption" do
    
    before(:each) do
      @user=User.create!(@attr)  
    end
    
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password attribute" do
      @user.encrypted_password.should_not be_blank
    end   
    
    it "should have a salt" do
      @user.should respond_to(:salt)
    end 
      
    describe "has_password? method" do  
      it "should exist" do
         @user.should respond_to(:encrypted_password)
      end
      
      it "should retun true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true 
      end
      
      it "should retun fals if the passwords don't match" do
        @user.has_password?('invalid test pw').should be_false 
      end
    end  
    
    describe "authenticate method" do 
      it "should have an authenticate method" do
        User.should respond_to(:authenticate)
      end 
           
      it "should return nil on email/password mismatch" do
        User.authenticate(@attr[:email], "wrongpassword").should be_nil 
      end
      
      it "should return nil with an email address with no user" do
        User.authenticate('xtest@wrongpw.com', "somepassword").should be_nil
      end
      
      it "should return the user on email/password match" do
        User.authenticate(@attr[:email], @attr[:password]) == @user 
      end
    end  
  end
  
  describe "admin attribute" do
    
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should respond to admin" do
      @user.should respond_to(:admin)
    end
    
    it "should not be and admin by default" do
      @user.should_not be_admin  # this willl call @user.admin? to check
      # Could also use @user.admin?.should_not be_true
    end
    
    it "should be convertible to an admin" do
      @user.toggle!(:admin)  # toggle! will swap the value of the :admin boolean column  
      @user.should be_admin
    end
  end
  
  describe "micropost associations" do
    
    before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago) 
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago) 
      # Note. Factorygirl lets us bypass the attr_accessible here, otherwise we wouldn't be able to set the the created_at
      
    end
    
    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end
    #This test is really not necessary, as the model asscociation should autamtically set these up properly
    #but still nice to write a test for this.
    
    it "should have the right micropost in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end
    
    it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end  
    end
    
    # Alternative way of testing for the same thing:
    it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        lambda do
          Micropost.find(micropost.id)
        end.should raise_error(ActiveRecord::RecordNotFound) # We got this value from testing in the consol for Micropost.find(1) for a non existing record
      end  
    end
    
    describe "status feed" do
      it "should have a feed" do
        @user.should respond_to(:feed)
      end
    end
    
    it "should include the user's microposts" do
      # @user.feed.include?(@mp1).should be_true
      # but now an amazing convention
      @user.feed.should include(@mp1)
      @user.feed.should include(@mp2)
    end

    it "should not include a different user's microposts" do
      # @user.feed.include?(@mp1).should be_true
      # but now an amazing convention
      
      @mp3 = Factory(:micropost, :user => Factory(:user, :email => Factory.next(:email)))

      @user.feed.should_not include(@mp3)
    end
  end
end  


