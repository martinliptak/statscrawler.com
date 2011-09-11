class DomainsController < ApplicationController
  def show

  end

  def search
    @title = "Search '#{params[:search]}' "
    @domains = Domain.page(params[:page]).where("name like ?", "#{params[:search]}%").order(:name)

    redirect_to @domains.first if @domains.count == 1 unless params[:page].present?
  end

end
