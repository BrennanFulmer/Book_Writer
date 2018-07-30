
class User < ActiveRecord::Base
  extend Slugifyer::ClassMethods

  has_secure_password
  has_many :books
  
  validates :username, :presence => true, :uniqueness => true
  validates :password, :presence => true

  def slug
    username.downcase.strip.gsub(/\p{P}/, '').gsub(/\W+/, '-')
  end
end
