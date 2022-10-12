# Starling Bank Technical Challenge

We’d like you to develop a “round-up” feature for Starling customers using our public developer API that is available to all customers and partners.

For a customer, take all the transactions in a given week and round them up to the nearest pound.
For example with spending of £4.35, £5.20 and £0.87, the round-up would be £1.58.
This amount should then be transferred into a savings goal, helping the customer save for future adventures.

## Content
* [Usage](#usage)
  * [Usage - Logging](#usage---logging)
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

## Usage

### Usage - Logging
The log level defaults to `info`, but you can set level via the command line argument `--log-level` or the environment variable `LOG_LEVEL` can be used to set the logging level. If both are set the command line value takes precedence.

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
