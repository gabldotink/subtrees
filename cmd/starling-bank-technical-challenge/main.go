package main

import (
	"flag"
	"io"
	"net/http"
	"os"

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
	accessToken := os.Getenv("ACCESS_TOKEN")

	if accessToken == "" {
		log.Fatal("The environment variable 'ACCESS_TOKEN' is not set.")
	}

	baseUrl := "https://api-sandbox.starlingbank.com/api/v2"

	client := http.Client{}
	request, err := http.NewRequest("GET", baseUrl+"/accounts", nil)

	if err != nil {
		log.WithError(err).Fatal("Failed to create a HTTP request.")
	}

	request.Header = http.Header{
		"Content-Type":  {"application/json"},
		"Authorization": {"Bearer " + accessToken},
	}

	response, err := client.Do(request)

	if err != nil {
		log.WithError(err).Fatal("Failed to perform the HTTP request.")
	}

	body, err := io.ReadAll(response.Body)

	if err != nil {
		log.WithError(err).Fatal("Failed to read the HTTP response's body.")
	}

	log.Info(string(body))
}
