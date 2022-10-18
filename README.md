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
  * [Add Reference/Note To Savings Goal Transfers](#add-referencenote-to-savings-goal-transfers)
  * [Round Up Minimum Threshold](#round-up-minimum-threshold)
* [Technical Future Improvements](#technical-future-improvements)
  * [Snapshot Testing](#snapshot-testing)
  * [API Retries](#api-retries)
  * [End-to-end Tests](#end-to-end-tests)
  * [Removing Primitive Types](#removing-primitive-types)
  * [Parse Create Savings Goal Response](#parse-create-savings-goal-response)
  * [Reducing Redundant CI](#reducing-redundant-ci)
  * [Stricter Assertions](#stricter-assertions)
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
To use this tool you first of all want to compile Go source code to a binary, see [setup](#setup) and [compiling](#compiling) on details to compile the binary.
Once we have the binary then we need to make the access token of the customer available to the tool, by exporting the access token to the environment variable `ACCESS_TOKEN`.
After the access token is set we can then execute the binary to perform the rounding up of transactions for a customer.

E.g.

```
earthly +compiling-darwin-amd64
export ACCESS_TOKEN="123"
./starling-bank-technical-challenge --log-level "DEBUG"
```

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

### Add Reference/Note To Savings Goal Transfers
The transfers from the account to the savings goal have no reference or note.
The lack of reference or note could be confusing for customers.
So adding a reference or note to the transfer detailing it is a round up and the transaction that caused it would improve the customer experience.

### Round Up Minimum Threshold
Each transaction round up is done separately, the round up transfers transaction id is the transaction id that caused it; so even if the tool is executed multiple times a round up for each transaction only happens once.
An improved customer experience before performing any round up transfers would be to check they have at least the total amount in their account.
Otherwise, we may drain the account of nearly all funds, leaving them open to overdraft fees or other issues.
Or we have a threshold for the account which when below(which could be configurable by the customer) then we perform no rounding up at all.

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

### End-to-end Tests
This project has multiple unit tests.
The unit tests test that valid JSON responses from Starling's API can be successfully parsed. 
In addition to testing business logic such as the savings goal to round up too selection. 
But the project has no tests which test the integration with Starling's API.
End-to-end tests could be added, which use a sandbox user but against the real API.
To add automated assertions that the integration has not been broken, and then it can also be added to the CI pipeline.

### Removing Primitive Types
Data such as the access token and the savings goal UID are being passed around as strings.
An improvement would be to refactor these from primitives to structures.
It stops whole categories of bugs at compile time, such as accidentally switching the order of parameters of the same type.
I already did something similar with the account UID being refactored to the type `AccountInformation` in `api/accounts/accounts.go`.

### Parse Create Savings Goal Response
This project if there are no savings goals creates one, to transfer the rounded up savings too.
The response from the call to Starling's API to create the savings goal is not parsed for the savings goal's information.
Instead, to save time writing the code to parse it, I just called the already existing logic to query all the existing savings goals.
An improvement to remove redundant API calls, would be to parse the response returned.

### Reducing Redundant CI
The GitHub Continuous Integration (CI) workflow runs on every pull request, even if no code or dependencies have changed.
This causes the CI to perform redundant compute when only documentation etc is changed.
An improvement we could implement to stop spending redundant resources, would be for steps such as compiling and unit testing to only run when code or dependencies have changed.
This could be accomplished using the tool [Is Affected](https://crates.io/crates/is_affected) I created.

### Stricter Assertions
The program currently only performs basic checks on the data.
As we are dealing with money, an improvement for correctness would be performing stricter checks on the data input.
Such as checking the account type of accounts before we perform rounding, or checking the currency of accounts compared to savings goals match, etc.
And default to not performing operations on accounts, transactions, savings goals etc that we are not certain we can correctly operate upon.

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
