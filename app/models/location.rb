class Location < ActiveRecord::Base
  has_many :domains
end
