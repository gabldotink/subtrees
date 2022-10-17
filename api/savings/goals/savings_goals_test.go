package goals

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestDecodeToSavingsGoalsWithNoSavingsGoals(t *testing.T) {
	// Given
	response := `{"savingsGoalList":[]}`
	expectedNumberOfSavingsGoals := 0

	// When
	returnedSavingsGoals, err := decodeToSavingsGoals(response)

	// Then
	assert.NoError(t, err)
	assert.Equal(t, expectedNumberOfSavingsGoals, len(returnedSavingsGoals))
}

func TestDecodeToSavingsGoalsWithOneSavingsGoalNoTarget(t *testing.T) {
	// Given
	response := `{"savingsGoalList":[{"savingsGoalUid":"savings-goal-1","name":"Trip to Paris","totalSaved":{"currency":"GBP","minorUnits":0}}]}`
	expectedNumberOfSavingsGoals := 1

	// When
	returnedSavingsGoals, err := decodeToSavingsGoals(response)

	// Then
	assert.NoError(t, err)
	assert.Equal(t, expectedNumberOfSavingsGoals, len(returnedSavingsGoals))
}

func TestDecodeToSavingsGoalsWithOneSavingsGoalWithTarget(t *testing.T) {
	// Given
	response := `{"savingsGoalList":[{"savingsGoalUid":"savings-goal-1","name":"Trip to Paris","target":{"currency":"GBP","minorUnits":123456},"totalSaved":{"currency":"GBP","minorUnits":123456},"savedPercentage":100}]}`
	expectedNumberOfSavingsGoals := 1

	// When
	returnedSavingsGoals, err := decodeToSavingsGoals(response)

	// Then
	assert.NoError(t, err)
	assert.Equal(t, expectedNumberOfSavingsGoals, len(returnedSavingsGoals))
}

func TestDecodeToSavingsGoalsWithMultipleSavingsGoals(t *testing.T) {
	// Given
	response := `{"savingsGoalList":[{"savingsGoalUid":"savings-goal-1","name":"Trip to Dublin","target":{"currency":"GBP","minorUnits":50000},"totalSaved":{"currency":"GBP","minorUnits":0},"savedPercentage":0},{"savingsGoalUid":"savings-goal-2","name":"Trip to London","totalSaved":{"currency":"GBP","minorUnits":0}},{"savingsGoalUid":"savings-goal-3","name":"Trip to Paris","totalSaved":{"currency":"GBP","minorUnits":20}}]}`
	expectedNumberOfSavingsGoals := 3

	// When
	returnedSavingsGoals, err := decodeToSavingsGoals(response)

	// Then
	assert.NoError(t, err)
	assert.Equal(t, expectedNumberOfSavingsGoals, len(returnedSavingsGoals))
}

func TestGetFirstAccountUidWithNoSavingsGoals(t *testing.T) {
	// Given
	response := `{"savingsGoalList":[]}`
	savingsGoals, err := decodeToSavingsGoals(response)
	assert.NoError(t, err)
	expectedSavingsGoalUid := ""

	// When
	returnedSavingsGoalUid := getFirstSavingsGoalUid(savingsGoals)

	// Then
	assert.Equal(t, expectedSavingsGoalUid, returnedSavingsGoalUid)
}

func TestGetFirstAccountUidWithMultipleSavingsGoals(t *testing.T) {
	// Given
	response := `{"savingsGoalList":[{"savingsGoalUid":"savings-goal-1","name":"Trip to Dublin","target":{"currency":"GBP","minorUnits":50000},"totalSaved":{"currency":"GBP","minorUnits":0},"savedPercentage":0},{"savingsGoalUid":"savings-goal-2","name":"Trip to London","totalSaved":{"currency":"GBP","minorUnits":0}},{"savingsGoalUid":"savings-goal-3","name":"Trip to Paris","totalSaved":{"currency":"GBP","minorUnits":20}}]}`
	savingsGoals, err := decodeToSavingsGoals(response)
	assert.NoError(t, err)
	expectedSavingsGoalUid := "savings-goal-1"

	// When
	returnedSavingsGoalUid := getFirstSavingsGoalUid(savingsGoals)

	// Then
	assert.Equal(t, expectedSavingsGoalUid, returnedSavingsGoalUid)
}
