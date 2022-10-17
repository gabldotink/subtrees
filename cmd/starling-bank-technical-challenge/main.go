package main

import (
	"flag"
	"os"

	"github.com/DeveloperC286/starlingbanktechnicalchallenge/api/accounts"
	"github.com/DeveloperC286/starlingbanktechnicalchallenge/api/savings/goals"
	"github.com/DeveloperC286/starlingbanktechnicalchallenge/api/transactions"

	log "github.com/sirupsen/logrus"
)

func main() {
	// Parse and set the logging level either via an environmetn variable or CLI parameter.
	cliLogLevel := flag.String("log-level", "", "The level of to display. Can also be set by the environment variable 'LOG_LEVEL'. Defaults to the value 'info'.")
	flag.Parse()

	logLevel := "info"

	// CLI provided takes precedence and then enviroment variable.
	if *cliLogLevel != "" {
		logLevel = *cliLogLevel
	} else if envLogLevel, envLogLevelSet := os.LookupEnv("LOG_LEVEL"); envLogLevelSet {
		logLevel = envLogLevel
	}

	parsedLogLevel, err := log.ParseLevel(logLevel)

	if err != nil {
		log.WithError(err).Fatalf("Failed to parse %q to a log level, the lalid log levels are %q.", logLevel, log.AllLevels)
	}

	log.SetLevel(parsedLogLevel)

	log.SetFormatter(&log.TextFormatter{
		DisableColors:          false,
		DisableTimestamp:       true,
		DisableLevelTruncation: true,
		PadLevelText:           true,
	})

	// Get API related environment variables.
	accessTokenEnvName := "ACCESS_TOKEN"
	accessToken := os.Getenv(accessTokenEnvName)

	if accessToken == "" {
		log.Fatalf("The environment variable %#v is not set.", accessTokenEnvName)
	}

	accountUid, err := accounts.GetAccountUid(accessToken)

	if err != nil {
		os.Exit(1)
	}
	log.Infof("Rounding up the transactions for the account %#v.", accountUid)

	roundUpTotal, err := transactions.GetLastWeeksTransactionsRoundUp(accessToken, accountUid)

	if err != nil {
		os.Exit(1)
	}

	log.Infof("The total transaction round up for the account %#v is %#v.", accountUid, roundUpTotal)

	savingsGoalUid, err := goals.GetSavingsGoalsUid(accessToken, accountUid)

	if err != nil {
		os.Exit(1)
	}

	log.Infof("The transaction round ups for the account %#v is being transfered to the savings goal %#v.", accountUid, savingsGoalUid)
}
