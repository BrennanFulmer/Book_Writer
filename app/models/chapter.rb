
class Chapter < ActiveRecord::Base
  extend Slugifyer::ClassMethods

  belongs_to :book

  validates :name, :presence => true
  validates :ordinal, :presence => true
  validates :book_id, :presence => true

  def slug
    name.downcase.strip.gsub(/_/, ' ').gsub(/\p{P}/, '').gsub(/\W+/, '-')
  end

  def self.unique_ordinal?(new_chapter)
    all? do |chapter|
      chapter.ordinal != new_chapter.ordinal
    end
  end

end
