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
	accountsJSON, err := getAccountsJSON(accessToken)

	if err != nil {
		return "", err
	}

	accounts, err := decodeToAccounts(accountsJSON)

	if err != nil {
		return "", err
	}

	return getFirstAccountUid(accounts)
}

func getAccountsJSON(accessToken string) (string, error) {
	log.Debug("Querying the accounts API to get a list of all accounts.")
	// We use the more verbose NewRequest so we can add headers/query parameters.
	request, err := http.NewRequest("GET", api.BaseUrl+"/accounts", nil)

	if err != nil {
		log.WithError(err).Error("Failed to create a HTTP request.")
		return "", err
	}

	// Adding the headers used for authentication.
	request.Header = http.Header{
		"Content-Type":  {"application/json"},
		"Authorization": {"Bearer " + accessToken},
	}

	client := http.Client{}
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
		log.WithFields(log.Fields{
			"err":  err,
			"body": string(body),
		}).Error("Failed to successfully query the Accounts API.")
		return "", err
	}

	log.Debug("Successfully quiered the accounts API.")
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

func decodeToAccounts(accountsJSON string) ([]account, error) {
	log.Debug("Decoding the JSON response from the accounts API.")
	decoder := json.NewDecoder(bytes.NewReader([]byte(accountsJSON)))
	decoder.DisallowUnknownFields()

	var accountsAPIResponse accountsAPIResponse
	err := decoder.Decode(&accountsAPIResponse)

	if err != nil {
		log.WithError(err).Error("Failed to parse the APIs response from JSON.")
		return []account{}, err
	}

	accounts := accountsAPIResponse.Accounts
	log.Debugf("Decoded %#v accounts from the JSON response from the accounts API.", len(accounts))
	return accounts, nil
}

func getFirstAccountUid(accounts []account) (string, error) {
	// See Technical Decisions in the README.md.
	if len(accounts) == 0 {
		err := errors.New("accounts: accounts array is empty")
		log.WithError(err).Error("The accounts APIs response had no accounts.")
		return "", err
	}

	return accounts[0].Uid, nil
}
