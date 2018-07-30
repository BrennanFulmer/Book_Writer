
class Book < ActiveRecord::Base
  extend Slugifyer::ClassMethods

  belongs_to :user
  has_many :chapters

  validates :title, :presence => true, :uniqueness => true
  validates :user_id, :presence => true

  def slug
    title.downcase.strip.gsub(/\p{P}/, '').gsub(/\W+/, '-')
  end
end
