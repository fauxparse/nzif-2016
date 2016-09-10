class PricesController < ApplicationController
  def index
    @packages = PackagePriceList.new(festival)
  end
end
