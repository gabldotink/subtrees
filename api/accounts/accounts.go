package accounts

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"net/http"

	"github.com/DeveloperC286/starlingbanktechnicalchallenge/api"

	log "github.com/sirupsen/logrus"
)

func GetAccountUid(accessToken string) (string, error) {
	accountsJson, err := getAccounts(accessToken)

	if err != nil {
		return "", err
	}

	return getFirstAccountUid(accountsJson)
}

func getAccounts(accessToken string) (string, error) {
	client := http.Client{}
	request, err := http.NewRequest("GET", api.BaseUrl+"/accounts", nil)

	if err != nil {
		log.WithError(err).Error("Failed to create a HTTP request.")
		return "", err
	}

	request.Header = http.Header{
		"Content-Type":  {"application/json"},
		"Authorization": {"Bearer " + accessToken},
	}

	response, err := client.Do(request)

	if err != nil {
		log.WithError(err).Error("Failed to perform the HTTP request.")
		return "", err
	}

	body, err := io.ReadAll(response.Body)

	if err != nil {
		log.WithError(err).Error("Failed to read the HTTP response's body.")
		return "", err
	}

	if response.StatusCode != 200 {
		err = errors.New("the HTTP status code was '" + response.Status + "' not 200")
		log.WithError(err).Error("Failed to successfully query the Accounts API.")
		return "", err
	}

	return string(body), nil
}

type accountsAPIResponse struct {
	Accounts []account `json:"accounts"`
}

type account struct {
	Uid       string `json:"accountUid"`
	Type      string `json:"accountType"`
	Category  string `json:"defaultCategory"`
	Currency  string `json:"currency"`
	CreatedAt string `json:"createdAt"`
	Name      string `json:"name"`
}

func getFirstAccountUid(accountsJson string) (string, error) {
	decoder := json.NewDecoder(bytes.NewReader([]byte(accountsJson)))
	decoder.DisallowUnknownFields()

	var accountsAPIResponse accountsAPIResponse
	err := decoder.Decode(&accountsAPIResponse)

	if err != nil {
		log.WithError(err).Error("Failed to parse the APIs response from JSON.")
		return "", err
	}

	accounts := accountsAPIResponse.Accounts

	// See Technical Decisions in the README.md.
	if len(accounts) == 0 {
		err = errors.New("accounts array was empty")
		log.WithError(err).Error("Failed to have a single account in the APIs response.")
		return "", err
	}

	return accounts[0].Uid, nil
}
