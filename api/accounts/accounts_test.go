package accounts

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetFirstAccountUidWithNoAccounts(t *testing.T) {
	// Given
	response := `{"accounts":[]}`

	// When
	_, err := getFirstAccountUid(response)

	// Then
	assert.Error(t, err)
	assert.EqualError(t, err, "accounts array was empty")
}

func TestGetFirstAccountUidWithSingleAccount(t *testing.T) {
	// Given
	response := `{"accounts":[{"accountUid":"account-1","accountType":"PRIMARY","defaultCategory":"category","currency":"GBP","createdAt":"2022-10-11T16:58:48.398Z","name":"Personal"}]}`
	expectedAccountUid := "account-1"

	// When
	returnedAccountUid, err := getFirstAccountUid(response)

	// Then
	assert.NoError(t, err)
	assert.Equal(t, expectedAccountUid, returnedAccountUid)
}

func TestGetFirstAccountUidWithMultipleAccounts(t *testing.T) {
	// Given
	response := `{"accounts":[{"accountUid":"account-1","accountType":"PRIMARY","defaultCategory":"category","currency":"GBP","createdAt":"2022-10-11T16:58:48.398Z","name":"Personal"},{"accountUid":"account-2","accountType":"PRIMARY","defaultCategory":"category","currency":"GBP","createdAt":"2022-10-11T16:58:48.398Z","name":"Personal"}]}`
	expectedAccountUid := "account-1"

	// When
	returnedAccountUid, err := getFirstAccountUid(response)

	// Then
	assert.NoError(t, err)
	assert.Equal(t, expectedAccountUid, returnedAccountUid)
}

func TestGetFirstAccountUidErrorsWithUnexpectedFormat(t *testing.T) {
	// Given
	response := `{"error":"invalid_token","error_description":"Could not validate provided access token"}`

	// When
	_, err := getFirstAccountUid(response)

	// Then
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "json: unknown field")
}
