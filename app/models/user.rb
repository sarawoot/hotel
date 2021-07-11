class User < ActiveRecord::Base
  # new columns need to be added here to be writable through mass assignment
  attr_accessible :username, :email, :password, :password_confirmation, :fname, :lname, :lang, :role, :hotel_src_id
  cattr_accessor :hotel_src, :current_user_id
  attr_accessor :password
  before_save :prepare_password
  before_create :hotel_src
  has_many :expenses
  has_many :log_move_rooms

  validates_presence_of :username, :fname, :lname, :lang, :role
  validates_uniqueness_of :username, :allow_blank => true
  validates_format_of :username, :with => /^[-\w\._@]+$/i, :allow_blank => true
  #validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 4, :allow_blank => true
  validates_length_of :username, :minimum => 3, :allow_blank => true

  # login can be either username or email address
  def self.authenticate(login, pass)
    user = find_by_username(login) || find_by_email(login)
    return user if user && user.password_hash == user.encrypt_password(pass)
  end

  def encrypt_password(pass)
    BCrypt::Engine.hash_secret(pass, password_salt)
  end
  
  def full_name
    [fname,lname].join(" ")
  end
  
  
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end

  private

  def prepare_password
    unless password.blank?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = encrypt_password(password)
    end
  end
end
