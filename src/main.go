package main

import (
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

func main() {
	accessToken := os.Getenv("ACCESS_TOKEN")

	if accessToken == "" {
		log.Fatalln("ACCESS_TOKEN is not set.")
	}

	baseUrl := "https://api-sandbox.starlingbank.com/api/v2"

	client := http.Client{}
	request, err := http.NewRequest("GET", baseUrl+"/accounts", nil)

	if err != nil {
		log.Fatalln(err)
	}

	request.Header = http.Header{
		"Content-Type":  {"application/json"},
		"Authorization": {"Bearer " + accessToken},
	}

	response, err := client.Do(request)

	if err != nil {
		log.Fatalln(err)
	}

	body, err := ioutil.ReadAll(response.Body)

	if err != nil {
		log.Fatalln(err)
	}

	log.Printf(string(body))
}
