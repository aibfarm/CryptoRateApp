package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

type ExchangeRateResponse struct {
	Symbol string  `json:"symbol"`
	Price  string  `json:"price"`
	Rate   float64 `json:"rate"`
	Time   string  `json:"time"`
}

type BinanceResponse struct {
	Symbol string `json:"symbol"`
	Price  string `json:"price"`
}

func getUSDTBTCRate() (*ExchangeRateResponse, error) {
	url := "https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT"
	log.Printf("[Go] Fetching data from Binance API: %s", url)
	
	resp, err := http.Get(url)
	if err != nil {
		log.Printf("[Go] ERROR: Failed to make request to Binance: %v", err)
		return nil, err
	}
	defer resp.Body.Close()

	log.Printf("[Go] Binance API response status: %d", resp.StatusCode)

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Printf("[Go] ERROR: Failed to read response body: %v", err)
		return nil, err
	}

	log.Printf("[Go] Binance API response body: %s", string(body))

	var binanceResp BinanceResponse
	if err := json.Unmarshal(body, &binanceResp); err != nil {
		log.Printf("[Go] ERROR: Failed to parse JSON: %v", err)
		return nil, err
	}

	log.Printf("[Go] Parsed Binance response: Symbol=%s, Price=%s", binanceResp.Symbol, binanceResp.Price)

	price, err := strconv.ParseFloat(binanceResp.Price, 64)
	if err != nil {
		log.Printf("[Go] ERROR: Failed to parse price to float: %v", err)
		return nil, err
	}

	usdtToBtcRate := 1.0 / price
	log.Printf("[Go] Calculated USDT/BTC rate: %f", usdtToBtcRate)

	result := &ExchangeRateResponse{
		Symbol: "USDT/BTC",
		Price:  binanceResp.Price,
		Rate:   usdtToBtcRate,
		Time:   time.Now().Format(time.RFC3339),
	}

	log.Printf("[Go] Returning result: %+v", result)
	return result, nil
}

func main() {
	r := gin.Default()

	config := cors.DefaultConfig()
	config.AllowAllOrigins = true
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	config.AllowHeaders = []string{"Origin", "Content-Length", "Content-Type", "Authorization"}
	r.Use(cors.New(config))

	r.GET("/health", func(c *gin.Context) {
		log.Printf("[Go] Health check endpoint called from %s", c.ClientIP())
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	r.GET("/api/exchange-rate/usdt-btc", func(c *gin.Context) {
		log.Printf("[Go] Exchange rate endpoint called from %s", c.ClientIP())
		log.Printf("[Go] Request headers: %+v", c.Request.Header)
		
		rate, err := getUSDTBTCRate()
		if err != nil {
			log.Printf("[Go] ERROR in exchange rate endpoint: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		
		log.Printf("[Go] Successfully returning exchange rate data to client")
		c.JSON(http.StatusOK, rate)
	})

	port := "8080"
	log.Printf("Server starting on port %s", port)
	r.Run(":" + port)
}