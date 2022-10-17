package goals

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"net/http"

	"github.com/DeveloperC286/starlingbanktechnicalchallenge/api"

	log "github.com/sirupsen/logrus"
)

func GetSavingsGoalsUid(accessToken string, accountUid string) (string, error) {
	savingsGoalsJSON, err := getSavingsGoalsJSON(accessToken, accountUid)

	if err != nil {
		return "", err
	}

	savingsGoals, err := decodeToSavingsGoals(savingsGoalsJSON)

	if err != nil {
		return "", err
	}

	return getFirstSavingsGoalUid(savingsGoals), nil
}

func getSavingsGoalsJSON(accessToken string, accountUid string) (string, error) {
	// We use the more verbose NewRequest so we can add headers/query parameters.
	request, err := http.NewRequest("GET", api.BaseUrl+"/account/"+accountUid+"/savings-goals", nil)

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

	return string(body), nil
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

func decodeToSavingsGoals(savingsGoalsJSON string) ([]savingsGoal, error) {
	decoder := json.NewDecoder(bytes.NewReader([]byte(savingsGoalsJSON)))
	decoder.DisallowUnknownFields()

	var savingsGoalsAPIResponse savingsGoalsAPIResponse
	err := decoder.Decode(&savingsGoalsAPIResponse)

	if err != nil {
		log.WithError(err).Error("Failed to parse the APIs response from JSON.")
		return []savingsGoal{}, err
	}

	return savingsGoalsAPIResponse.SavingsGoals, nil
}

func getFirstSavingsGoalUid(savingsGoals []savingsGoal) string {
	if len(savingsGoals) == 0 {
		log.Warn("The savings goals APIs response had no savings goals.")
		return ""
	}

	return savingsGoals[0].Uid
}
