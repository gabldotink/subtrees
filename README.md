# Starling Bank Technical Challenge

We’d like you to develop a “round-up” feature for Starling customers using our public developer API that is available to all customers and partners.

For a customer, take all the transactions in a given week and round them up to the nearest pound.
For example with spending of £4.35, £5.20 and £0.87, the round-up would be £1.58.
This amount should then be transferred into a savings goal, helping the customer save for future adventures.

## Content
* [Usage](#usage)
  * [Usage - Logging](#usage---logging)
* [Technical Decisions](#technical-decisions)
  * [Language Choice](#language-choice)
* [Customer Experience Future Improvements](#customer-experience-future-improvements)
  * [Support Multiple Accounts](#support-multiple-accounts)
  * [Smarter Savings Goals Choice](#smarter-savings-goals-choice)
* [Technical Future Improvements](#technical-future-improvements)
  * [Snapshot Testing](#snapshot-testing)
  * [API Retries](#api-retries)
* [Development](#development)
  * [Setup](#setup)
  * [Commands](#commands)
    * [Check Formatting](#check-formatting)
    * [Fix Formatting](#fix-formatting)
    * [Linting](#linting)
    * [Linting](#linting)
    * [Check Module Tidying](#check-module-tidying)
    * [Fix Module Tidying](#fix-module-tidying)
    * [Compiling](#compiling)
    * [Unit Testing](#unit-testing)

## Usage

### Usage - Logging
The log level defaults to `info`.
But you can set the log level via the command line argument `--log-level` or the environment variable `LOG_LEVEL`.
If a level is provided via the command line and the environment variable, then the command line level is used.

## Technical Decisions
### Language Choice
I choose to use Go for several reasons.
The first is because it is a simple language, making projects very maintainable.
Go has excellent support for HTTP and JSON in the standard library.
Go is statically typed, helping to catch bugs when the stakes are high, like when working with money.
Go also has excellent performance charismatics.

## Customer Experience Future Improvements
### Support Multiple Accounts
To make it simpler currently only a singular account is supported.
If multiple are returned by the Starling API, then it only actions upon the first account.
Support could easily be added for rounding up multiple accounts by having `GetAccount()` in `api/accounts/accounts.go` return an array.

### Smarter Savings Goals Choice
The savings goal to transfer the rounded up savings too is just the first savings goal.
For an improved customer experience, we could add intelligence to the selected savings goal.
Initially, we could exclude from the choice all savings goals at or exceeding their target.
Then, other logic such as selecting the savings goal closest to its target.

## Technical Future Improvements
### Snapshot Testing
This project has unit tests asserting that valid JSON responses from Starling's API can be successfully parsed.
The unit tests only assert that the parsing did not error and on the number of objects returned.
Constructing and asserting upon the expected array of objects would produce low-value and fragile tests, as the tests are asserting upon the structure of internal data models, not on behaviour.
Snapshot testing could be added, which takes a snapshot of your output and compares it against the snapshot committed alongside your test.
Snapshot testing would have the benefits of adding more assertions on the structure of internal data models and reducing fragility while making the tests easier to update, as you do not have to cumbersomely construct the expected array of objects.

### API Retries
Currently, a single HTTP request is made and if it returns a server error (5xx) then the error is propagated and the program exits unsuccessfully.
Fault tolerance for these server errors could be added by implementing retries in our client with an exponential backoff algorithm.

### Improved Logging

### End-to-end Tests

### Removing Primitive Types

### More Checking of types

## Development
[🌍 Earthly](https://earthly.dev) is used as the build tool, it is a CI/CD framework that allows you to develop pipelines locally and run them anywhere.
Earthly leverages containers for the execution of pipelines.
This makes them self-contained, repeatable, portable and parallel.

### Setup
You only need Earthly and Docker installed, Earthly handles all build and runtime dependencies.

* [Get Earthly](https://earthly.dev/get-earthly)
* [Get Docker](https://www.docker.com/get-started/)

### Commands
#### Check Formatting
You can check the source code is correctly formatted by running the command.

```
earthly +check-formatting
```

#### Fix Formatting
You can fix the formatting of the source code by running the command.

```
earthly +fix-formatting
```

#### Linting
You can lint the source code by running the command.

```
earthly +linting
```

#### Check Module Tidying
You can check there are no missing or redundant module requirements by running the command.

```
earthly +check-module-tidying
```

#### Fix Module Tidying
You can fix missing or redundant module requirements by running the command.

```
earthly +fix-module-tidying
```

#### Compiling
You can compile the source code into a binary by running the command.

```
earthly +compiling-linux-amd64
```

or

```
earthly +compiling-darwin-amd64
```

#### Unit Testing
You can run all the unit tests by running the command.

```
earthly +unit-testing
```
