package main

import (
	"io"
	"net/http"
	"os"

	log "github.com/sirupsen/logrus"
)

func main() {
	accessToken := os.Getenv("ACCESS_TOKEN")

	if accessToken == "" {
		log.Fatal("The environment variable 'ACCESS_TOKEN' is not set.")
	}

	baseUrl := "https://api-sandbox.starlingbank.com/api/v2"

	client := http.Client{}
	request, err := http.NewRequest("GET", baseUrl+"/accounts", nil)

	if err != nil {
		log.WithError(err).Fatal("Failed to create a HTTP request.")
	}

	request.Header = http.Header{
		"Content-Type":  {"application/json"},
		"Authorization": {"Bearer " + accessToken},
	}

	response, err := client.Do(request)

	if err != nil {
		log.WithError(err).Fatal("Failed to perform the HTTP request.")
	}

	body, err := io.ReadAll(response.Body)

	if err != nil {
		log.WithError(err).Fatal("Failed to read the HTTP response's body.")
	}

	log.Info(string(body))
}
