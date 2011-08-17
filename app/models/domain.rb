class Domain < ActiveRecord::Base
  belongs_to :page, :dependent => :destroy
  belongs_to :location, :dependent => :destroy
  has_many :list_domains
  
  after_create :enqueue_analyzer
  
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
  
  def enqueue_analyzer
    Resque.enqueue(Analyzers::Performer, self.id)
  end
end
