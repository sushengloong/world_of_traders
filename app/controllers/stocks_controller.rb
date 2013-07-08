class StocksController < ApplicationController
  HOT_STOCKS = %w{ T39.SI S68.SI Z74.SI CC3.SI B2F.SI U11.SI O39.SI D05.SI C6L.SI F99.SI }
  DATA_MAPPING = [:symbol, :name, :last_trade_price, :last_trade_date, :last_trade_time, :open, :high, :low, :dividend_per_share, :pe_ratio]

  def index
    @hot_stocks = []
    hydra = Typhoeus::Hydra.new
    HOT_STOCKS.each do |stock_symbol|
      request = Typhoeus::Request.new "http://finance.yahoo.com/d/quotes.csv?s=#{stock_symbol}&f=snl1d1t1ohgdr", method: :get, followlocation: true
      request.on_complete do |response|
        if response.success?
          if response.success?
            response_data = response.body.split(',').map { |d| d.strip.chomp.gsub '"', '' }
            @hot_stocks << response_data.inject({}) do |stocks, col|
              stocks.tap do |s|
                s[DATA_MAPPING[s.length]] = col
              end
            end
          elsif response.timed_out?
            # aw hell no
            "got a time out"
          elsif response.code == 0
            # Could not get an http response, something's wrong.
            response.curl_error_message
          else
            # Received a non-successful http response.
            "HTTP request failed: " + response.code.to_s
          end
        end
      end
      hydra.queue request
    end
    hydra.run
    @hot_stocks.sort_by! { |x| x[:symbol] }
  end

  def show
  end

  def search
  end
end
