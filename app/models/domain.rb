class Domain < ActiveRecord::Base
  belongs_to :page
  belongs_to :location

  before_save :set_tld_from_name

  before_destroy :destroy_orphaned_pages
  before_destroy :destroy_orphaned_locations

  def to_param
    name.gsub('.', '_')
  end

  def url
    if name.tr('^.', '').size > 1
      "http://#{name}"
    else
      "http://www.#{name}"
    end
  end
  
  def analyze
    yield(self)
    self.analyzed_at = Time.now
    save
  end

  def self.to_be_analyzed
    where(:analyzed_at => nil)
  end

  def self.analyzed
    where('analyzed_at IS NOT NULL')
  end

  private

  def destroy_orphaned_pages
    page.destroy if page and page.domains.count == 1
  end

  def destroy_orphaned_locations
    location.destroy if location and location.domains.count == 1
  end

  def set_tld_from_name
    m = /.(\w+)$/.match(name);
    write_attribute(:tld, m[1]) if m and m[1]
  end
end
