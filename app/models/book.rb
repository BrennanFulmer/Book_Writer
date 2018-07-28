
class Book < ActiveRecord::Base
  extend Slugifyer::ClassMethods

  belongs_to :user
  has_many :chapters

  def slug
    title.downcase.strip.gsub(/\p{P}/, '').gsub(/\W+/, '-')
  end
end
