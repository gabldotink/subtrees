package accounts

import (
	"io"
	"net/http"

	"github.com/DeveloperC286/starlingbanktechnicalchallenge/api"

	log "github.com/sirupsen/logrus"
)

func GetAccounts(accessToken string) {
	client := http.Client{}
	request, err := http.NewRequest("GET", api.BaseUrl+"/accounts", nil)

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
