require 'digest/sha2'
class User < ActiveRecord::Base
  after_destroy :ensure_an_admin_remains
  validates :name,:presence=>true,:uniqueness=>true
  validates_length_of:name,:minimum=>3,:message=>"is too short"
  validates_length_of:name,:maximum=>10,:message=>"is too long"
  validates_length_of:password,:maximum=>12,:message=>"is too long"
  validates_length_of:password,:minimum=>3,:message=>"is too short"
  validates :password,:confirmation=>true
  attr_accessor:password_confirmation
  attr_reader :password
  validate :password_must_be_present
  
  has_many :comments
  has_many :orders
  
  class<<self
    def authenticate(name,password)
      if user=find_by_name(name)
        if user.hashed_password==encrypt_password(password,user.salt)
          user
        end
      end
    end
    
    def encrypt_password(password,salt)
      Digest::SHA2.hexdigest(password+"wibble"+salt)
    end
  end
  
  def ensure_an_admin_remains
    if User.count.zero?
      raise "Can't delete last user"
    end
  end
  
  def password=(password)
       @password=password
    if password.present?
       generate_salt
       self.hashed_password=self.class.encrypt_password(password,salt)
    end
  end
  
  private 
     def password_must_be_present
         errors.add(:password,"Missing password")unless hashed_password.present?
     end
     
     def generate_salt
       self.salt=self.object_id.to_s+rand.to_s
     end
end 

