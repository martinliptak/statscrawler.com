class Domain < ActiveRecord::Base
  belongs_to :page
  belongs_to :location
  has_many :list_domains

  before_destroy :destroy_orphaned_pages
  before_destroy :destroy_orphaned_locations
  
  def analyze
    yield(self)
    self.analyzed_at = Time.now
    save
  end
  
  def self.create_from_list(list, domain_name)
    domain = find_or_create_by_name(domain_name)
    domain.list_domains.create :list => list
  end

  private

  def destroy_orphaned_pages
    page.destroy if page and page.domains.count == 1
  end

  def destroy_orphaned_locations
    location.destroy if location and location.domains.count == 1
  end
end
