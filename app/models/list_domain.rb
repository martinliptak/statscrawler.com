class ListDomain < ActiveRecord::Base
  belongs_to :domain
  
  before_destroy :destroy_orphaned_domains
  
  private
  
  def destroy_orphaned_domains
    domain.destroy if domain.list_domains.count == 1  
  end
end
