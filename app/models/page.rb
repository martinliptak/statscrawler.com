class Page < ActiveRecord::Base
  has_many :features
  has_one :source
end
