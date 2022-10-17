package transactions

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestDecodeToTransactionsWithNoTransactions(t *testing.T) {
	// Given
	transactionsJSON := `{"feedItems":[]}`
	expectedNumberOfTransactions := 0

	// When
	returnedTransactions, err := decodeToTransactions([]byte(transactionsJSON))

	// Then
	assert.NoError(t, err)
	assert.Equal(t, expectedNumberOfTransactions, len(returnedTransactions))
}

func TestDecodeToTransactionsWithOneTransaction(t *testing.T) {
	// Given
	transactionsJSON := `{"feedItems":[{"feedItemUid":"feed-1","categoryUid":"category-1","amount":{"currency":"GBP","minorUnits":617},"sourceAmount":{"currency":"GBP","minorUnits":617},"direction":"OUT","updatedAt":"2022-10-11T16:59:39.153Z","transactionTime":"2022-10-11T16:59:38.526Z","settlementTime":"2022-10-11T16:59:39.029Z","source":"FASTER_PAYMENTS_OUT","status":"SETTLED","transactingApplicationUserUid":"transacting-application-user-1","counterPartyType":"PAYEE","counterPartyUid":"counter-party-1","counterPartyName":"Mickey Mouse","counterPartySubEntityUid":"counter-party-sub-entity-1","counterPartySubEntityName":"UK account","counterPartySubEntityIdentifier":"204514","counterPartySubEntitySubIdentifier":"00000825","reference":"External Payment","country":"GB","spendingCategory":"PAYMENTS","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null}]}`
	expectedNumberOfTransactions := 1

	// When
	returnedTransactions, err := decodeToTransactions([]byte(transactionsJSON))

	// Then
	assert.NoError(t, err)
	assert.Equal(t, expectedNumberOfTransactions, len(returnedTransactions))
}

func TestDecodeToTransactionsWithMultipleTransactions(t *testing.T) {
	// Given
	transactionsJSON := `{"feedItems":[{"feedItemUid":"feed-1","categoryUid":"category-1","amount":{"currency":"GBP","minorUnits":2965},"sourceAmount":{"currency":"GBP","minorUnits":2965},"direction":"IN","updatedAt":"2022-10-11T16:59:38.743Z","transactionTime":"2022-10-11T16:59:38.000Z","settlementTime":"2022-10-11T16:59:38.000Z","source":"FASTER_PAYMENTS_IN","status":"SETTLED","counterPartyType":"SENDER","counterPartyName":"Faster payment","counterPartySubEntityName":"","counterPartySubEntityIdentifier":"600522","counterPartySubEntitySubIdentifier":"20028318","reference":"Ref: 4163163642","country":"GB","spendingCategory":"INCOME","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null},{"feedItemUid":"feed-2","categoryUid":"category-2","amount":{"currency":"GBP","minorUnits":617},"sourceAmount":{"currency":"GBP","minorUnits":617},"direction":"OUT","updatedAt":"2022-10-11T16:59:39.153Z","transactionTime":"2022-10-11T16:59:38.526Z","settlementTime":"2022-10-11T16:59:39.029Z","source":"FASTER_PAYMENTS_OUT","status":"SETTLED","transactingApplicationUserUid":"transacting-application-user-1","counterPartyType":"PAYEE","counterPartyUid":"counter-party-1","counterPartyName":"Mickey Mouse","counterPartySubEntityUid":"counter-party-sub-entity-1","counterPartySubEntityName":"UK account","counterPartySubEntityIdentifier":"204514","counterPartySubEntitySubIdentifier":"00000825","reference":"External Payment","country":"GB","spendingCategory":"PAYMENTS","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null}]}`
	expectedNumberOfTransactions := 2

	// When
	returnedTransactions, err := decodeToTransactions([]byte(transactionsJSON))

	// Then
	assert.NoError(t, err)
	assert.Equal(t, expectedNumberOfTransactions, len(returnedTransactions))
}

func TestGetRoundUpTotalWithNoTransactions(t *testing.T) {
	// Given
	transactionsJSON := `{"feedItems":[]}`
	transactions, err := decodeToTransactions([]byte(transactionsJSON))
	assert.NoError(t, err)
	expectedRoundUpTotal := 0

	// When
	returnedRoundUpTotal := getRoundUpTotal(transactions)

	// Then
	assert.Equal(t, expectedRoundUpTotal, returnedRoundUpTotal)
}

func TestGetRoundUpTotalWithOneTransaction(t *testing.T) {
	// Given
	transactionsJSON := `{"feedItems":[{"feedItemUid":"feed-1","categoryUid":"category-1","amount":{"currency":"GBP","minorUnits":617},"sourceAmount":{"currency":"GBP","minorUnits":617},"direction":"OUT","updatedAt":"2022-10-11T16:59:39.153Z","transactionTime":"2022-10-11T16:59:38.526Z","settlementTime":"2022-10-11T16:59:39.029Z","source":"FASTER_PAYMENTS_OUT","status":"SETTLED","transactingApplicationUserUid":"transacting-application-user-1","counterPartyType":"PAYEE","counterPartyUid":"counter-party-1","counterPartyName":"Mickey Mouse","counterPartySubEntityUid":"counter-party-sub-entity-1","counterPartySubEntityName":"UK account","counterPartySubEntityIdentifier":"204514","counterPartySubEntitySubIdentifier":"00000825","reference":"External Payment","country":"GB","spendingCategory":"PAYMENTS","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null}]}`
	transactions, err := decodeToTransactions([]byte(transactionsJSON))
	assert.NoError(t, err)
	expectedRoundUpTotal := 83

	// When
	returnedRoundUpTotal := getRoundUpTotal(transactions)

	// Then
	assert.Equal(t, expectedRoundUpTotal, returnedRoundUpTotal)
}

func TestGetRoundUpTotalWithMultipleTransactions(t *testing.T) {
	// Given
	transactionsJSON := `{"feedItems":[{"feedItemUid":"feed-1","categoryUid":"category-1","amount":{"currency":"GBP","minorUnits":50000},"sourceAmount":{"currency":"GBP","minorUnits":50000},"direction":"IN","updatedAt":"2022-10-11T16:59:38.033Z","transactionTime":"2022-10-11T16:59:37.000Z","settlementTime":"2022-10-11T16:59:37.000Z","source":"FASTER_PAYMENTS_IN","status":"SETTLED","counterPartyType":"SENDER","counterPartyName":"Faster payment","counterPartySubEntityName":"","counterPartySubEntityIdentifier":"600522","counterPartySubEntitySubIdentifier":"20028210","reference":"Ref: 8772855118","country":"GB","spendingCategory":"INCOME","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null},{"feedItemUid":"feed-2","categoryUid":"category-2","amount":{"currency":"GBP","minorUnits":2965},"sourceAmount":{"currency":"GBP","minorUnits":2965},"direction":"IN","updatedAt":"2022-10-11T16:59:38.743Z","transactionTime":"2022-10-11T16:59:38.000Z","settlementTime":"2022-10-11T16:59:38.000Z","source":"FASTER_PAYMENTS_IN","status":"SETTLED","counterPartyType":"SENDER","counterPartyName":"Faster payment","counterPartySubEntityName":"","counterPartySubEntityIdentifier":"600522","counterPartySubEntitySubIdentifier":"20028318","reference":"Ref: 4163163642","country":"GB","spendingCategory":"INCOME","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null},{"feedItemUid":"feed-3","categoryUid":"category-3","amount":{"currency":"GBP","minorUnits":200000},"sourceAmount":{"currency":"GBP","minorUnits":200000},"direction":"IN","updatedAt":"2022-10-11T16:59:38.246Z","transactionTime":"2022-10-11T16:59:38.000Z","settlementTime":"2022-10-11T16:59:38.000Z","source":"FASTER_PAYMENTS_IN","status":"SETTLED","counterPartyType":"SENDER","counterPartyName":"Faster payment","counterPartySubEntityName":"","counterPartySubEntityIdentifier":"600522","counterPartySubEntitySubIdentifier":"20028237","reference":"Ref: 8938159201","country":"GB","spendingCategory":"INCOME","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null},{"feedItemUid":"feed-4","categoryUid":"category-4","amount":{"currency":"GBP","minorUnits":1989},"sourceAmount":{"currency":"GBP","minorUnits":1989},"direction":"IN","updatedAt":"2022-10-11T16:59:38.514Z","transactionTime":"2022-10-11T16:59:38.000Z","settlementTime":"2022-10-11T16:59:38.000Z","source":"FASTER_PAYMENTS_IN","status":"SETTLED","counterPartyType":"SENDER","counterPartyName":"Faster payment","counterPartySubEntityName":"","counterPartySubEntityIdentifier":"600522","counterPartySubEntitySubIdentifier":"20028288","reference":"Ref: 3273194500","country":"GB","spendingCategory":"INCOME","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null},{"feedItemUid":"feed-5","categoryUid":"category-5","amount":{"currency":"GBP","minorUnits":1768},"sourceAmount":{"currency":"GBP","minorUnits":1768},"direction":"IN","updatedAt":"2022-10-11T16:59:38.863Z","transactionTime":"2022-10-11T16:59:38.000Z","settlementTime":"2022-10-11T16:59:38.000Z","source":"FASTER_PAYMENTS_IN","status":"SETTLED","counterPartyType":"SENDER","counterPartyName":"Faster payment","counterPartySubEntityName":"","counterPartySubEntityIdentifier":"600522","counterPartySubEntitySubIdentifier":"20028334","reference":"Ref: 9961676053","country":"GB","spendingCategory":"INCOME","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null},{"feedItemUid":"feed-6","categoryUid":"category-6","amount":{"currency":"GBP","minorUnits":901},"sourceAmount":{"currency":"GBP","minorUnits":901},"direction":"IN","updatedAt":"2022-10-11T16:59:38.491Z","transactionTime":"2022-10-11T16:59:38.000Z","settlementTime":"2022-10-11T16:59:38.000Z","source":"FASTER_PAYMENTS_IN","status":"SETTLED","counterPartyType":"SENDER","counterPartyName":"Faster payment","counterPartySubEntityName":"","counterPartySubEntityIdentifier":"600522","counterPartySubEntitySubIdentifier":"20028261","reference":"Ref: 5133696988","country":"GB","spendingCategory":"INCOME","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null},{"feedItemUid":"feed-7","categoryUid":"category-7","amount":{"currency":"GBP","minorUnits":2646},"sourceAmount":{"currency":"GBP","minorUnits":2646},"direction":"IN","updatedAt":"2022-10-11T16:59:39.461Z","transactionTime":"2022-10-11T16:59:39.000Z","settlementTime":"2022-10-11T16:59:39.000Z","source":"FASTER_PAYMENTS_IN","status":"SETTLED","counterPartyType":"SENDER","counterPartyName":"Faster payment","counterPartySubEntityName":"","counterPartySubEntityIdentifier":"600522","counterPartySubEntitySubIdentifier":"20025076","reference":"Ref: 2747851752","country":"GB","spendingCategory":"INCOME","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null},{"feedItemUid":"feed-8","categoryUid":"category-8","amount":{"currency":"GBP","minorUnits":215},"sourceAmount":{"currency":"GBP","minorUnits":215},"direction":"IN","updatedAt":"2022-10-11T16:59:39.172Z","transactionTime":"2022-10-11T16:59:39.000Z","settlementTime":"2022-10-11T16:59:39.000Z","source":"FASTER_PAYMENTS_IN","status":"SETTLED","counterPartyType":"SENDER","counterPartyName":"Faster payment","counterPartySubEntityName":"","counterPartySubEntityIdentifier":"600522","counterPartySubEntitySubIdentifier":"20025041","reference":"Ref: 7373132007","country":"GB","spendingCategory":"INCOME","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null},{"feedItemUid":"feed-9","categoryUid":"category-9","amount":{"currency":"GBP","minorUnits":617},"sourceAmount":{"currency":"GBP","minorUnits":617},"direction":"OUT","updatedAt":"2022-10-11T16:59:39.153Z","transactionTime":"2022-10-11T16:59:38.526Z","settlementTime":"2022-10-11T16:59:39.029Z","source":"FASTER_PAYMENTS_OUT","status":"SETTLED","transactingApplicationUserUid":"transacting-application-user-1","counterPartyType":"PAYEE","counterPartyUid":"counter-party-1","counterPartyName":"Mickey Mouse","counterPartySubEntityUid":"counter-party-sub-entity-1","counterPartySubEntityName":"UK account","counterPartySubEntityIdentifier":"204514","counterPartySubEntitySubIdentifier":"00000825","reference":"External Payment","country":"GB","spendingCategory":"PAYMENTS","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null},{"feedItemUid":"feed-10","categoryUid":"category-10","amount":{"currency":"GBP","minorUnits":2838},"sourceAmount":{"currency":"GBP","minorUnits":2838},"direction":"OUT","updatedAt":"2022-10-11T16:59:39.189Z","transactionTime":"2022-10-11T16:59:38.569Z","settlementTime":"2022-10-11T16:59:39.049Z","source":"FASTER_PAYMENTS_OUT","status":"SETTLED","transactingApplicationUserUid":"transacting-application-user-2","counterPartyType":"PAYEE","counterPartyUid":"counter-party-2","counterPartySubEntityUid":"counter-party-sub-entity-2","counterPartySubEntityName":"UK account","counterPartySubEntityIdentifier":"204514","counterPartySubEntitySubIdentifier":"00000825","reference":"External Payment","country":"GB","spendingCategory":"PAYMENTS","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null},{"feedItemUid":"feed-11","categoryUid":"category-11","amount":{"currency":"GBP","minorUnits":1937},"sourceAmount":{"currency":"GBP","minorUnits":1937},"direction":"OUT","updatedAt":"2022-10-11T16:59:39.323Z","transactionTime":"2022-10-11T16:59:38.772Z","settlementTime":"2022-10-11T16:59:39.221Z","source":"FASTER_PAYMENTS_OUT","status":"SETTLED","transactingApplicationUserUid":"transacting-application-user-3","counterPartyType":"PAYEE","counterPartyUid":"counter-party-3","counterPartyName":"Mickey Mouse","counterPartySubEntityUid":"counter-party-sub-entity-3","counterPartySubEntityName":"UK account","counterPartySubEntityIdentifier":"204514","counterPartySubEntitySubIdentifier":"00000825","reference":"External Payment","country":"GB","spendingCategory":"PAYMENTS","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null},{"feedItemUid":"feed-12","categoryUid":"category-12","amount":{"currency":"GBP","minorUnits":2890},"sourceAmount":{"currency":"GBP","minorUnits":2890},"direction":"OUT","updatedAt":"2022-10-11T16:59:39.465Z","transactionTime":"2022-10-11T16:59:38.997Z","settlementTime":"2022-10-11T16:59:39.360Z","source":"FASTER_PAYMENTS_OUT","status":"SETTLED","transactingApplicationUserUid":"transacting-application-user-4","counterPartyType":"PAYEE","counterPartyUid":"counter-party-4","counterPartyName":"Mickey Mouse","counterPartySubEntityUid":"counter-party-sub-entity-4","counterPartySubEntityName":"UK account","counterPartySubEntityIdentifier":"204514","counterPartySubEntitySubIdentifier":"00000825","reference":"External Payment","country":"GB","spendingCategory":"PAYMENTS","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null},{"feedItemUid":"feed-13","categoryUid":"category-13","amount":{"currency":"GBP","minorUnits":1628},"sourceAmount":{"currency":"GBP","minorUnits":1628},"direction":"OUT","updatedAt":"2022-10-11T16:59:39.868Z","transactionTime":"2022-10-11T16:59:39.348Z","settlementTime":"2022-10-11T16:59:39.761Z","source":"FASTER_PAYMENTS_OUT","status":"SETTLED","transactingApplicationUserUid":"transacting-application-user-5","counterPartyType":"PAYEE","counterPartyUid":"counter-party-5","counterPartyName":"Mickey Mouse","counterPartySubEntityUid":"counter-party-sub-entity-5","counterPartySubEntityName":"UK account","counterPartySubEntityIdentifier":"204514","counterPartySubEntitySubIdentifier":"00000825","reference":"External Payment","country":"GB","spendingCategory":"PAYMENTS","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null},{"feedItemUid":"feed-14","categoryUid":"category-14","amount":{"currency":"GBP","minorUnits":2563},"sourceAmount":{"currency":"GBP","minorUnits":2563},"direction":"OUT","updatedAt":"2022-10-11T16:59:40.157Z","transactionTime":"2022-10-11T16:59:39.556Z","settlementTime":"2022-10-11T16:59:40.072Z","source":"FASTER_PAYMENTS_OUT","status":"SETTLED","transactingApplicationUserUid":"transacting-application-user-6","counterPartyType":"PAYEE","counterPartyUid":"counter-party-6","counterPartyName":"Mickey Mouse","counterPartySubEntityUid":"counter-party-sub-entity-6","counterPartySubEntityName":"UK account","counterPartySubEntityIdentifier":"204514","counterPartySubEntitySubIdentifier":"00000825","reference":"External Payment","country":"GB","spendingCategory":"PAYMENTS","hasAttachment":false,"hasReceipt":false,"batchPaymentDetails":null}]}`
	transactions, err := decodeToTransactions([]byte(transactionsJSON))
	assert.NoError(t, err)
	expectedRoundUpTotal := 327

	// When
	returnedRoundUpTotal := getRoundUpTotal(transactions)

	// Then
	assert.Equal(t, expectedRoundUpTotal, returnedRoundUpTotal)
}
