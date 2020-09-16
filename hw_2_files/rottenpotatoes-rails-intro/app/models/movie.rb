class Movie < ActiveRecord::Base
    def self.movie_ratings
        self.distinct.pluck(:rating)
    end
end
