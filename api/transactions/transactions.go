package transactions

import (
	"errors"
	"io"
	"net/http"
	"time"

	"github.com/DeveloperC286/starlingbanktechnicalchallenge/api"

	log "github.com/sirupsen/logrus"
)

func GetTransactions(accessToken string, accountUid string) {
	// We use the more verbose NewRequest so we can add headers/query parameters.
	request, err := http.NewRequest("GET", api.BaseUrl+"/feed/account/"+accountUid+"/settled-transactions-between", nil)

	if err != nil {
		log.WithError(err).Error("Failed to create a HTTP request.")
		return
	}

	// Adding the date of transactions between query paramters.
	now := time.Now().UTC()
	weekAgo := now.AddDate(0, 0, -7)

	q := request.URL.Query()
	q.Add("minTransactionTimestamp", weekAgo.Format(time.RFC3339))
	q.Add("maxTransactionTimestamp", now.Format(time.RFC3339))
	request.URL.RawQuery = q.Encode()

	// Adding the headers used for authentication.
	request.Header = http.Header{
		"Content-Type":  {"application/json"},
		"Authorization": {"Bearer " + accessToken},
	}

	client := http.Client{}
	response, err := client.Do(request)

	if err != nil {
		log.WithError(err).Error("Failed to perform the HTTP request.")
		return
	}

	body, err := io.ReadAll(response.Body)

	if err != nil {
		log.WithError(err).Error("Failed to read the HTTP response's body.")
		return
	}

	if response.StatusCode != 200 {
		err = errors.New("the HTTP status code was '" + response.Status + "' not 200")
		log.WithFields(log.Fields{
			"err":  err,
			"body": string(body),
		}).Error("Failed to successfully query the Accounts API.")
		return
	}

	log.Info(string(body))
}
