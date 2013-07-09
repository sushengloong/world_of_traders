require 'yahoo_finance_client'

class StocksController < ApplicationController

  def index
    @hot_stocks = YahooFinanceClient.sti_components
  end

  def show
  end

  def search
  end
end
