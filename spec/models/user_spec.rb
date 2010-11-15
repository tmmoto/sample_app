require 'spec_helper'

describe User do
  
  before(:each) do
    @attr = { :name => "Example User", 
              :email => "user@example.com", 
              :password => "AsupErPw", 
              :password_confirmation => "AsupErPw" 
              }
  end
  
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
      @user=User.create(@attr)
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
      User.new(@attr.merge(:password =>"", :password_confimration => "")).should_not be_valid
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
  end
  
end


