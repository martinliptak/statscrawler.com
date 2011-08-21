class Page < ActiveRecord::Base
  has_many :domains
  has_many :features, :dependent => :destroy
  has_one :source, :dependent => :destroy
end
