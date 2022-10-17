package goals

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"net/http"

	"github.com/DeveloperC286/starlingbanktechnicalchallenge/api"
	"github.com/DeveloperC286/starlingbanktechnicalchallenge/api/accounts"

	log "github.com/sirupsen/logrus"
)

func CreateSavingsGoal(accessToken string, accountInformation accounts.AccountInformation) (string, error) {
	err := createSavingsGoal(accessToken, accountInformation)

	if err != nil {
		return "", err
	}

	return GetSavingsGoalsUid(accessToken, accountInformation)
}

func createSavingsGoal(accessToken string, accountInformation accounts.AccountInformation) error {
	log.Debug("Creating a savings goals using the Savings Goals API endpoint.")
	JSON := []byte(`{"name": "Round Up Savings","currency": "` + accountInformation.Currency + `"}`)
	// We use the more verbose NewRequest so we can add headers/query parameters.
	request, err := http.NewRequest("PUT", api.BaseUrl+"/account/"+accountInformation.Uid+"/savings-goals", bytes.NewBuffer(JSON))

	if err != nil {
		log.WithError(err).Error("Failed to create a HTTP request.")
		return err
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
		return err
	}

	if response.StatusCode != 200 {
		err = errors.New("the HTTP status code was '" + response.Status + "' not 200")
		log.WithFields(log.Fields{
			"err": err,
		}).Error("Failed to put to the Savings Goals API endpoint.")
		return err
	}

	log.Debug("Successfully created a savings goals using the Savings Goals API endpoint.")
	return nil
}

func GetSavingsGoalsUid(accessToken string, accountInformation accounts.AccountInformation) (string, error) {
	savingsGoals, err := getSavingsGoals(accessToken, accountInformation)

	if err != nil {
		return "", err
	}

	return getFirstSavingsGoalUid(savingsGoals), nil
}

func getSavingsGoals(accessToken string, accountInformation accounts.AccountInformation) ([]savingsGoal, error) {
	log.Debug("Getting a list of all savings goals from the Savings Goals API endpoint.")
	// We use the more verbose NewRequest so we can add headers/query parameters.
	request, err := http.NewRequest("GET", api.BaseUrl+"/account/"+accountInformation.Uid+"/savings-goals", nil)

	if err != nil {
		log.WithError(err).Error("Failed to create a HTTP request.")
		return []savingsGoal{}, err
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
		return []savingsGoal{}, err
	}

	savingsGoalsJSON, err := io.ReadAll(response.Body)

	if err != nil {
		log.WithError(err).Error("Failed to read the HTTP response's body.")
		return []savingsGoal{}, err
	}

	if response.StatusCode != 200 {
		err = errors.New("the HTTP status code was '" + response.Status + "' not 200")
		log.WithFields(log.Fields{
			"err":  err,
			"body": string(savingsGoalsJSON),
		}).Error("Failed to get from the Savings Goals API endpoint.")
		return []savingsGoal{}, err
	}

	log.Debug("Successfully got a list of all savings goals from the Savings Goals API endpoint.")
	return decodeToSavingsGoals(savingsGoalsJSON)
}

type savingsGoalsAPIResponse struct {
	SavingsGoals []savingsGoal `json:"savingsGoalList"`
}

type savingsGoal struct {
	Uid             string `json:"savingsGoalUid"`
	Name            string `json:"name"`
	Target          amount `json:"target"`
	Saved           amount `json:"totalSaved"`
	SavedPercentage int    `json:"savedPercentage"`
}

type amount struct {
	Currency string `json:"currency"`
	Value    int    `json:"minorUnits"`
}

func decodeToSavingsGoals(savingsGoalsJSON []byte) ([]savingsGoal, error) {
	log.Debug("Decoding the JSON response from the Savings Goals API endpoint.")
	decoder := json.NewDecoder(bytes.NewReader(savingsGoalsJSON))
	decoder.DisallowUnknownFields()

	var savingsGoalsAPIResponse savingsGoalsAPIResponse
	err := decoder.Decode(&savingsGoalsAPIResponse)

	if err != nil {
		log.WithError(err).Error("Failed to parse the JSON.")
		return []savingsGoal{}, err
	}

	savingsGoals := savingsGoalsAPIResponse.SavingsGoals
	log.Debugf("Decoded %#v savings goals from the JSON response from the Savings Goals API endpoint.", len(savingsGoals))
	return savingsGoals, nil
}

func getFirstSavingsGoalUid(savingsGoals []savingsGoal) string {
	if len(savingsGoals) == 0 {
		log.Warn("The Savings Goals APIs endpoint returned no savings goals.")
		return ""
	}

	return savingsGoals[0].Uid
}
