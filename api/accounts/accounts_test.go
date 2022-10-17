package accounts

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestDecodeToAccountsWithNoAccounts(t *testing.T) {
	// Given
	accountsJSON := `{"accounts":[]}`
	expectedNumberOfAccounts := 0

	// When
	returnedAccounts, err := decodeToAccounts([]byte(accountsJSON))

	// Then
	assert.NoError(t, err)
	assert.Equal(t, expectedNumberOfAccounts, len(returnedAccounts))
}

func TestDecodeToAccountsWithSingleAccount(t *testing.T) {
	// Given
	accountsJSON := `{"accounts":[{"accountUid":"account-1","accountType":"PRIMARY","defaultCategory":"category","currency":"GBP","createdAt":"2022-10-11T16:58:48.398Z","name":"Personal"}]}`
	expectedNumberOfAccounts := 1

	// When
	returnedAccounts, err := decodeToAccounts([]byte(accountsJSON))

	// Then
	assert.NoError(t, err)
	assert.Equal(t, expectedNumberOfAccounts, len(returnedAccounts))
}

func TestDecodeToAccountsWithMultipleAccounts(t *testing.T) {
	// Given
	accountsJSON := `{"accounts":[{"accountUid":"account-1","accountType":"PRIMARY","defaultCategory":"category","currency":"GBP","createdAt":"2022-10-11T16:58:48.398Z","name":"Personal"},{"accountUid":"account-2","accountType":"PRIMARY","defaultCategory":"category","currency":"GBP","createdAt":"2022-10-11T16:58:48.398Z","name":"Personal"}]}`
	expectedNumberOfAccounts := 2

	// When
	returnedAccounts, err := decodeToAccounts([]byte(accountsJSON))

	// Then
	assert.NoError(t, err)
	assert.Equal(t, expectedNumberOfAccounts, len(returnedAccounts))
}

func TestDecodeToAccountsErrorsWithUnexpectedFormat(t *testing.T) {
	// Given
	accountsJSON := `{"error":"invalid_token","error_description":"Could not validate provided access token"}`

	// When
	_, err := decodeToAccounts([]byte(accountsJSON))

	// Then
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "json: unknown field")
}

func TestGetFirstAccountUidWithNoAccounts(t *testing.T) {
	// Given
	accountsJSON := `{"accounts":[]}`
	accounts, err := decodeToAccounts([]byte(accountsJSON))
	assert.NoError(t, err)
	expectedErrorMessage := "accounts: accounts array is empty"

	// When
	_, err = getFirstAccount(accounts)

	// Then
	assert.Error(t, err)
	assert.EqualError(t, err, expectedErrorMessage)
}

func TestGetFirstAccountUidWithSingleAccount(t *testing.T) {
	// Given
	accountsJSON := `{"accounts":[{"accountUid":"account-1","accountType":"PRIMARY","defaultCategory":"category","currency":"GBP","createdAt":"2022-10-11T16:58:48.398Z","name":"Personal"}]}`
	accounts, err := decodeToAccounts([]byte(accountsJSON))
	assert.NoError(t, err)
	expectedAccountInformation := AccountInformation{
		Uid:      "account-1",
		Currency: "GBP",
	}

	// When
	returnedAccountInformation, err := getFirstAccount(accounts)

	// Then
	assert.NoError(t, err)
	assert.Equal(t, expectedAccountInformation, returnedAccountInformation)
}

func TestGetFirstAccountUidWithMultipleAccounts(t *testing.T) {
	// Given
	accountsJSON := `{"accounts":[{"accountUid":"account-1","accountType":"PRIMARY","defaultCategory":"category","currency":"GBP","createdAt":"2022-10-11T16:58:48.398Z","name":"Personal"},{"accountUid":"account-2","accountType":"PRIMARY","defaultCategory":"category","currency":"GBP","createdAt":"2022-10-11T16:58:48.398Z","name":"Personal"}]}`
	accounts, err := decodeToAccounts([]byte(accountsJSON))
	assert.NoError(t, err)
	expectedAccountInformation := AccountInformation{
		Uid:      "account-1",
		Currency: "GBP",
	}

	// When
	returnedAccountInformation, err := getFirstAccount(accounts)

	// Then
	assert.NoError(t, err)
	assert.Equal(t, expectedAccountInformation, returnedAccountInformation)
}
