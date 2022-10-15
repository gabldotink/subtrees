package transactions

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"time"

	"github.com/DeveloperC286/starlingbanktechnicalchallenge/api"

	log "github.com/sirupsen/logrus"
)

func GetLastWeeksTransactionsRoundUp(accessToken string, accountUid string) (int, error) {
	transactionsJSON, err := getLastWeeksTransactionsJSON(accessToken, accountUid)

	if err != nil {
		return 0, err
	}

	transactions, err := decodeToTransactions(transactionsJSON)

	if err != nil {
		return 0, err
	}

	return getRoundUpTotal(transactions), nil
}

func getLastWeeksTransactionsJSON(accessToken string, accountUid string) (string, error) {
	// We use the more verbose NewRequest so we can add headers/query parameters.
	request, err := http.NewRequest("GET", api.BaseUrl+"/feed/account/"+accountUid+"/settled-transactions-between", nil)

	if err != nil {
		log.WithError(err).Error("Failed to create a HTTP request.")
		return "", err
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

type transactionsAPIResponse struct {
	Transactions []transaction `json:"feedItems"`
}

type transaction struct {
	FeedItemUid                        string `json:"feedItemUid"`
	CategoryUid                        string `json:"categoryUid"`
	Amount                             amount `json:"amount"`
	SourceAmount                       amount `json:"sourceAmount"`
	Direction                          string `json:"direction"`
	UpdatedAt                          string `json:"updatedAt"`
	TransactionTime                    string `json:"transactionTime"`
	SettlementTime                     string `json:"settlementTime"`
	Source                             string `json:"source"`
	Status                             string `json:"status"`
	TransactingApplicationUserUid      string `json:"transactingApplicationUserUid"`
	CounterPartyType                   string `json:"counterPartyType"`
	CounterPartyUid                    string `json:"counterPartyUid"`
	CounterPartyName                   string `json:"counterPartyName"`
	CounterPartySubEntityName          string `json:"counterPartySubEntityName"`
	CounterPartySubEntityUid           string `json:"counterPartySubEntityUid"`
	CounterPartySubEntityIdentifier    string `json:"counterPartySubEntityIdentifier"`
	CounterPartySubEntitySubIdentifier string `json:"counterPartySubEntitySubIdentifier"`
	Reference                          string `json:"reference"`
	Country                            string `json:"country"`
	SpendingCategory                   string `json:"spendingCategory"`
	HasAttachment                      bool   `json:"hasAttachment"`
	HasReceipt                         bool   `json:"hasReceipt"`
	BatchPaymentDetails                string `json:"batchPaymentDetails"`
}

type amount struct {
	Currency string `json:"currency"`
	Value    int    `json:"minorUnits"`
}

func decodeToTransactions(transactionsJSON string) ([]transaction, error) {
	decoder := json.NewDecoder(bytes.NewReader([]byte(transactionsJSON)))
	decoder.DisallowUnknownFields()

	var transactionsAPIResponse transactionsAPIResponse
	err := decoder.Decode(&transactionsAPIResponse)

	if err != nil {
		log.WithError(err).Error("Failed to parse the APIs response from JSON.")
		return []transaction{}, err
	}

	return transactionsAPIResponse.Transactions, nil
}

func getRoundUpTotal(transactions []transaction) int {
	roundUpTotal := 0

	for _, transaction := range transactions {
		if transaction.Direction == "OUT" {
			roundUpTotal += (100 - (transaction.Amount.Value % 100))
		}
	}

	return roundUpTotal
}
