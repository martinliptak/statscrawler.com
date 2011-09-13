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
    unless domain.list_domains.where(:list => list).any?
      domain.list_domains.create(:list => list)
    end
    domain
  end

  def self.to_be_analyzed
    where(:analyzed_at => nil)
  end

  def self.analyzed
    where('analyzed_at IS NOT NULL')
  end

  def url
    if name.tr('^.', '').size > 1
      "http://#{name}"
    else
      "http://www.#{name}"
    end
  end

  private

  def destroy_orphaned_pages
    page.destroy if page and page.domains.count == 1
  end

  def destroy_orphaned_locations
    location.destroy if location and location.domains.count == 1
  end
end
