
class Chapter < ActiveRecord::Base
  extend Slugifyer::ClassMethods

  belongs_to :book

  def slug
    name.downcase.strip.gsub(/\p{P}/, '').gsub(/\W+/, '-')
  end
end
