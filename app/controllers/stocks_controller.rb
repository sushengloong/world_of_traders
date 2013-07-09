class StocksController < ApplicationController
  HOT_STOCKS = %w{ T39.SI S68.SI Z74.SI CC3.SI B2F.SI U11.SI O39.SI D05.SI C6L.SI F99.SI }

  YAHOO_DATA_MAPPING = {
    "s" => [ "symbol", "val" ],
    "n" => [ "name", "val" ],
    "l1" => [ "lastTrade", "val.to_f" ],
    "d1" => [ "date", "val" ],
    "t1" => [ "time", "val" ],
    "c" => [ "change", "val" ],
    "c1" => [ "changePoints", "val.to_f" ],
    "p2" => [ "changePercent", "val.to_f" ],
    "p" => [ "previousClose", "val.to_f" ],
    "o" => [ "open", "val.to_f" ],
    "h" => [ "dayHigh", "val.to_f" ],
    "g" => [ "dayLow", "val.to_f" ],
    "v" => [ "volume", "val.to_i" ],
    "m" => [ "dayRange", "val" ],
    "l" => [ "lastTradeWithTime", "val" ],
    "t7" => [ "tickerTrend", "convert(val)" ],
    "a2" => [ "averageDailyVolume", "val.to_i" ],
    "b" => [ "bid", "val.to_f" ],
    "a" => [ "ask", "val.to_f" ],

    "w" => [ "weeks52Range", "val" ],
    "j5" => [ "weeks52ChangeFromLow", "val.to_f" ],
    "j6" => [ "weeks52ChangePercentFromLow", "val" ],
    "k4" => [ "weeks52ChangeFromHigh", "val.to_f" ],
    "k5" => [ "weeks52ChangePercentFromHigh", "val" ],
    "e" => [ "earningsPerShare", "val.to_f" ],
    "r" => [ "peRatio", "val.to_f" ],
    "s7" => [ "shortRatio", "val" ],
    "r1" => [ "dividendPayDate", "val" ],
    "q" => [ "exDividendDate", "val" ],
    "d" => [ "dividendPerShare", "convert(val)" ],
    "y" => [ "dividendYield", "convert(val)" ],
    "j1" => [ "marketCap", "convert(val)" ],
    "t8" => [ "oneYearTargetPrice", "val" ],
    "e7" => [ "epsEstimateCurrentYear", "val" ],
    "e8" => [ "epsEstimateNextYear", "val" ],
    "e9" => [ "epsEstimateNextQuarter", "val" ],
    "r6" => [ "pricePerEPSEstimateCurrentYear", "val" ],
    "r7" => [ "pricePerEPSEstimateNextYear", "val" ],
    "r5" => [ "pegRatio", "val.to_f" ],
    "b4" => [ "bookValue", "val.to_f" ],
    "p6" => [ "pricePerBook", "val.to_f" ],
    "p5" => [ "pricePerSales", "val.to_f" ],
    "j4" => [ "ebitda", "val" ],
    "m3" => [ "movingAve50days", "val" ],
    "m7" => [ "movingAve50daysChangeFrom", "val" ],
    "m8" => [ "movingAve50daysChangePercentFrom", "val" ],
    "m4" => [ "movingAve200days", "val" ],
    "m5" => [ "movingAve200daysChangeFrom", "val" ],
    "m6" => [ "movingAve200daysChangePercentFrom", "val" ],
    "s1" => [ "sharesOwned", "val" ],
    "p1" => [ "pricePaid", "val" ],
    "c3" => [ "commission", "val" ],
    "v1" => [ "holdingsValue", "val" ],
    "w1" => [ "dayValueChange", "val" ],
    "g1" => [ "holdingsGainPercent", "val" ],
    "g4" => [ "holdingsGain", "val" ],
    "d2" => [ "tradeDate", "val" ],
    "g3" => [ "annualizedGain", "val" ],
    "l2" => [ "highLimit", "val" ],
    "l3" => [ "lowLimit", "val" ],
    "n4" => [ "notes", "val" ],
    "x" => [ "stockExchange", "val" ],


    "b2" => [ "rt_ask", "val.to_f" ],
    "b3" => [ "rt_bid", "val.to_f" ],
    "k2" => [ "rt_change", "val" ],
    "k1" => [ "rt_lastTradeWithTime", "val" ],
    "c6" => [ "rt_changePoints", "val.to_f" ],
    "m2" => [ "rt_dayRange", "val" ],
    "j3" => [ "rt_marketCap", "convert(val)" ],
  }

  def index
    @hot_stocks = []
    hydra = Typhoeus::Hydra.new
    HOT_STOCKS.each do |stock_symbol|
      request = Typhoeus::Request.new "http://finance.yahoo.com/d/quotes.csv?s=#{stock_symbol}&f=#{YAHOO_DATA_MAPPING.keys.join}", method: :get, followlocation: true
      request.on_complete do |response|
        if response.success?
          if response.success?
            response_data = response.body.split(',').map { |d| d.strip.chomp.gsub '"', '' }
            @hot_stocks << response_data.inject({}) do |stocks, col|
              stocks.tap do |s|
                key = YAHOO_DATA_MAPPING.keys[s.length]
                s[YAHOO_DATA_MAPPING[key][0].to_sym] = col
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
