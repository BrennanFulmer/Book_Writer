
module Slugifyer

  module ClassMethods
    def find_by_slug(slug)
      all.detect { |instance| instance.slug == slug }
    end
  end

end
