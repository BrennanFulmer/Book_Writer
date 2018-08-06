
class User < ActiveRecord::Base
  extend Slugifyer::ClassMethods

  has_secure_password
  has_many :books

  validates :username, :presence => true, :uniqueness => true,
  length: { in: 5..32 }, format: { with: /\A[a-z0-9][a-z0-9 ]{4,31}\Z/i }

  def slug
    username.downcase.strip.gsub(/\p{P}/, '').gsub(/\W+/, '-')
  end

end
