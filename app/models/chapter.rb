
class Chapter < ActiveRecord::Base
  extend Slugifyer::ClassMethods

  belongs_to :book

  validates :name, :presence => true, length: { in: 5..64 },
  format: { with: /\A[a-z0-9][a-z0-9 ]{4,63}\Z/i }

  validates :ordinal, :presence => true, numericality: { only_integer: true },
  length: { in: 1..2 }, format: { with: /\A[1-9][0-9]{0,1}\Z/ }

  validates :book_id, :presence => true, numericality: { only_integer: true }

  def slug
    name.downcase.strip.gsub(/\p{P}/, '').gsub(/\W+/, '-')
  end

end
