
class Chapter < ActiveRecord::Base
  extend Slugifyer::ClassMethods

  belongs_to :book

  validates :name, :presence => true
  validates :ordinal, :presence => true
  validates :book_id, :presence => true

  def slug
    name.downcase.strip.gsub(/_/, ' ').gsub(/\p{P}/, '').gsub(/\W+/, '-')
  end

end
