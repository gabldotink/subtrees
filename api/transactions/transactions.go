package transactions

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"time"

	"github.com/DeveloperC286/starlingbanktechnicalchallenge/api"
	"github.com/DeveloperC286/starlingbanktechnicalchallenge/api/accounts"

	log "github.com/sirupsen/logrus"
)

func GetLastWeeksTransactionsRoundUp(accessToken string, accountInformation accounts.AccountInformation) ([]RoundUpOperation, error) {
	transactions, err := getLastWeeksTransactions(accessToken, accountInformation)

	if err != nil {
		return []RoundUpOperation{}, err
	}

	return getRoundUpOperations(transactions), nil
}

func getLastWeeksTransactions(accessToken string, accountInformation accounts.AccountInformation) ([]transaction, error) {
	log.Debug("Getting a list of all the transaction from last week from the Transaction Feed API endpoint.")
	// We use the more verbose NewRequest so we can add headers/query parameters.
	request, err := http.NewRequest("GET", api.BaseUrl+"/feed/account/"+accountInformation.Uid+"/settled-transactions-between", nil)

	if err != nil {
		log.WithError(err).Error("Failed to create a HTTP request.")
		return []transaction{}, err
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
		return []transaction{}, err
	}

	transactionsJSON, err := io.ReadAll(response.Body)

	if err != nil {
		log.WithError(err).Error("Failed to read the HTTP response's body.")
		return []transaction{}, err
	}

	if response.StatusCode != 200 {
		err = errors.New("the HTTP status code was '" + response.Status + "' not 200")
		log.WithFields(log.Fields{
			"err":  err,
			"body": string(transactionsJSON),
		}).Error("Failed to get from the Transaction Feed API endpoint.")
		return []transaction{}, err
	}

	log.Debug("Successfully got a list of all the transaction from last week from the Transaction Feed API endpoint.")
	return decodeToTransactions(transactionsJSON)
}

type transactionsAPIResponse struct {
	Transactions []transaction `json:"feedItems"`
}

type transaction struct {
	Uid                                string `json:"feedItemUid"`
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

func decodeToTransactions(transactionsJSON []byte) ([]transaction, error) {
	log.Debug("Decoding the JSON response from the Transaction Feed API endpoint.")
	decoder := json.NewDecoder(bytes.NewReader(transactionsJSON))
	decoder.DisallowUnknownFields()

	var transactionsAPIResponse transactionsAPIResponse
	err := decoder.Decode(&transactionsAPIResponse)

	if err != nil {
		log.WithError(err).Error("Failed to parse the JSON.")
		return []transaction{}, err
	}

	transactions := transactionsAPIResponse.Transactions
	log.Debugf("Decoded %#v transactions from the JSON response from the Transaction Feed API endpoint.", len(transactions))
	return transactions, nil
}

type RoundUpOperation struct {
	Uid      string
	Currency string
	Value    int
}

func getRoundUpOperations(transactions []transaction) []RoundUpOperation {
	roundUpOperations := []RoundUpOperation{}

	for _, transaction := range transactions {
		if transaction.Direction == "OUT" {
			transactionRoundUp := (100 - (transaction.Amount.Value % 100))

			if transactionRoundUp != 100 {
				log.Tracef("The transaction %#v is being rounded up by %#v.", transaction.Uid, transactionRoundUp)
				roundUpOperations = append(roundUpOperations, RoundUpOperation{
					Uid:      transaction.Uid,
					Currency: transaction.Amount.Currency,
					Value:    transactionRoundUp,
				})
			}
		}
	}

	return roundUpOperations
}
