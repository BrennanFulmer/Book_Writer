
class Book < ActiveRecord::Base
  extend Slugifyer::ClassMethods

  belongs_to :user
  has_many :chapters

  validates :title, :presence => true, :uniqueness => true
  validates :user_id, :presence => true

  def slug
    title.downcase.strip.gsub(/_/, ' ').gsub(/\p{P}/, '').gsub(/\W+/, '-')
  end

  def unique_ordinal?(new_chapter)
    chapters.all? do |chapter|
      chapter.ordinal != new_chapter.ordinal
    end
  end

end
