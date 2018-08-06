
class Book < ActiveRecord::Base
  extend Slugifyer::ClassMethods

  belongs_to :user
  has_many :chapters

  validates :title, :presence => true, :uniqueness => true,
  length: { in: 5..64 }, format: { with: /\A[a-z0-9][a-z0-9 ]{4,63}\Z/i }

  validates :user_id, :presence => true, numericality: { only_integer: true }

  def slug
    title.downcase.strip.gsub(/\p{P}/, '').gsub(/\W+/, '-')
  end

end
