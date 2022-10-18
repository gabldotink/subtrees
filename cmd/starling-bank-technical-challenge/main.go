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
	defaultLogLevel := "info"
	envLogLevelName := "LOG_LEVEL"

	// Reading in log level from the CLI.
	cliLogLevel := flag.String("log-level", "", "The level of to display. Can also be set by the environment variable '"+envLogLevelName+"'. Defaults to the value '"+defaultLogLevel+"'.")
	flag.Parse()

	// Reading in log level from env.
	envLogLevel, envLogLevelSet := os.LookupEnv(envLogLevelName)

	logLevel := ""

	// If you specify an option by using a parameter on the command line, it overrides any value from the corresponding environment variable.
	if *cliLogLevel != "" {
		log.Info("Setting the log level from the command line parameter.")
		logLevel = *cliLogLevel
	} else if envLogLevelSet {
		log.Info("Setting the log level from the environment variable.")
		logLevel = envLogLevel
	} else {
		log.Info("Setting the log level from the default.")
		logLevel = defaultLogLevel
	}

	parsedLogLevel, err := log.ParseLevel(logLevel)

	if err != nil {
		log.WithError(err).Fatalf("Failed to parse %q to a log level, the valid log levels are %q.", logLevel, log.AllLevels)
	}

	log.Infof("Setting the log level to %q.", logLevel)
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

	account, err := accounts.GetAccount(accessToken)

	if err != nil {
		os.Exit(1)
	}
	log.Infof("Rounding up the transactions for the account %#v.", account.Uid)

	roundUpOperations, err := transactions.GetLastWeeksTransactionsRoundUp(accessToken, account)

	if err != nil {
		os.Exit(1)
	}

	log.Infof("%#v transaction round ups for the account %#v.", len(roundUpOperations), account.Uid)

	if len(roundUpOperations) == 0 {
		os.Exit(0)
	}

	savingsGoalUid, err := goals.GetSavingsGoalsUid(accessToken, account)

	if err != nil {
		os.Exit(1)
	}

	if savingsGoalUid == "" {
		log.Info("No savings goal, creating a savings goals for the round up savings.")
		savingsGoalUid, err = goals.CreateSavingsGoal(accessToken, account)

		if err != nil {
			os.Exit(1)
		}
	}

	log.Infof("The transaction round ups for the account %#v are being transfered to the savings goal %#v.", account.Uid, savingsGoalUid)
	err = goals.PerformRoundUpOperations(accessToken, account, savingsGoalUid, roundUpOperations)

	if err != nil {
		os.Exit(1)
	}

	log.Info("Successfully transfered all the transaction round ups.")
}
