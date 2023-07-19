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

func GetAccount(accessToken string) (AccountInformation, error) {
	accounts, err := getAccounts(accessToken)

	if err != nil {
		return AccountInformation{}, err
	}

	return getFirstAccount(accounts)
}

func getAccounts(accessToken string) ([]account, error) {
	log.Debug("Getting a list of all accounts from the Accounts API endpoint.")
	// We use the more verbose NewRequest so we can add headers/query parameters.
	request, err := http.NewRequest("GET", api.BaseUrl+"/accounts", nil)

	if err != nil {
		log.WithError(err).Error("Failed to create a HTTP request.")
		return []account{}, err
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
		return []account{}, err
	}

	accountsJSON, err := io.ReadAll(response.Body)

	if err != nil {
		log.WithError(err).Error("Failed to read the HTTP response's body.")
		return []account{}, err
	}

	if response.StatusCode != 200 {
		err = errors.New("the HTTP status code was '" + response.Status + "' not 200")
		log.WithFields(log.Fields{
			"err":  err,
			"body": string(accountsJSON),
		}).Error("Failed to get from the Accounts API endpoint.")
		return []account{}, err
	}

	log.Debug("Successfully got a list of all accounts from the Accounts API endpoint.")
	return decodeToAccounts(accountsJSON)
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

func decodeToAccounts(accountsJSON []byte) ([]account, error) {
	log.Debug("Decoding the JSON response from the Accounts API endpoint.")
	decoder := json.NewDecoder(bytes.NewReader(accountsJSON))
	decoder.DisallowUnknownFields()

	var accountsAPIResponse accountsAPIResponse
	err := decoder.Decode(&accountsAPIResponse)

	if err != nil {
		log.WithError(err).Error("Failed to parse the JSON.")
		return []account{}, err
	}

	accounts := accountsAPIResponse.Accounts
	log.Debugf("Decoded %#v accounts from the JSON response from the Accounts API endpoint.", len(accounts))
	return accounts, nil
}

type AccountInformation struct {
	Uid      string
	Currency string
}

func getFirstAccount(accounts []account) (AccountInformation, error) {
	// See Technical Decisions in the README.md.
	if len(accounts) == 0 {
		err := errors.New("accounts: accounts array is empty")
		log.WithError(err).Error("The Accounts APIs endpoint returned no accounts.")
		return AccountInformation{}, err
	}

	accountInformation := AccountInformation{
		Uid:      accounts[0].Uid,
		Currency: accounts[0].Currency,
	}
	return accountInformation, nil
}
