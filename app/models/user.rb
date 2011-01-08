# == Schema Information
# Schema version: 20101220203245
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean
#

class User < ActiveRecord::Base
  attr_accessor   :password  #  This creates “getter” and “setter” methods that allow us to retrieve (get) and assign (set) @name and @email instance variables.
  attr_accessible :name, :email, :password, :password_confirmation
  #Note: password was created by thhe attr_accessor, while :password_confirmation is created 
  # as a result of the password validation, created by rails, from the validates :password lines
  
  has_many :microposts, :dependent => :destroy
  
  email_regex = /\A[\w.+\-]+@[a-z.\d\-]+\.[a-z]+\z/i
  
  validates :name,  :presence   => true,
                    :length     => { :maximum => 50 }
  validates :email, :presence   => true,  
                    :format     => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }
  validates :password, :presence => true,
                       :confirmation => true,    # This line creates a password_confirmation attribute
                       :length => { :within => 6..40 }
                        
  before_save :encrypt_password
  
  
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end
  

  def User.authenticate(email, submitted_password)   # This is a class function (by using User. or self.  in the def)
    auser = find_by_email(email)
    # return nil if auser.nil?
    # return auser if auser.has_password?(submitted_password)   # I don't like this version. This implicitly says that if we don't test with the    
                                                               #right pw, than just return nil by getting to the end of the block without
                                                               
    (auser && auser.has_password?(submitted_password)) ? auser : nil                                                              
  end
  
  def User.authenticate_with_salt(id, cookie_salt)  #Cookie salt is the salt value that we stored in the cookie and will to authenticate with
    user = find_by_id(id)
    (user && user.salt = cookie_salt) ? user : nil #  Ternary operator
    
  end
  
private
  
  def encrypt_password
    self.salt = make_salt if new_record?         # new_record is a method in active record. Question: what happens when salt is added to old records?
    self.encrypted_password = encrypt(password)   # need a self so that ruby knows we are referring to a method here, 
                                                 # other wise this will be interpreted as a local variable.
  end
          
  def encrypt(string)
    secure_hash("#{salt}--#{string}")  # temp solution for testing
  end
  
  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end            
  
  def make_salt
    secure_hash("#{Time.now.utc}--#{password}}")   
  end
  
end 




