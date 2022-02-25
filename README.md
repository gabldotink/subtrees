Quickly spin up a MediaWiki instance with the [VueTest](https://gitlab.wikimedia.org/egardner/mediawiki-extensions-vuetest) extension.

## Installation 

Clone this repo:

    git clone https://gitlab.wikimedia.org/mhurd/mediawiki-cirrus-docker.git

## Usage

Switch to the `mediawiki-cirrus-docker` directory:

    cd ~/mediawiki-cirrus-docker

Use this command to spin up MediaWiki with the CirrusSearch:
-   ```
    make freshinstallwithvuetestextension
     ```
    - Fetches the latest MediaWiki into `~/mediawiki-cirrus-docker/mediawiki/`
    - Fetches the latest Elastica extension into `~/mediawiki-cirrus-docker/mediawiki/extensions/Elastica`
    - Fetches the latest CirrusSearch extension into `~/mediawiki-cirrus-docker/mediawiki/extensions/CirrusSearch`
    - Configures MediaWiki to use the Elastica and CirrusSearch extensions
    - Spins up Docker containment to serve MediaWiki pages
    - Opens pages showing search results including a `Special:Search` url with '&cirrusDumpQuery' - which should display json containing the elasticsearch query if CirrusSearch is being used ( from https://www.mediawiki.org/wiki/Topic:Vspistlf132kafvm )

See the [Makefile](https://gitlab.wikimedia.org/mhurd/mediawiki-cirrus-docker/-/blob/main/Makefile) for other supported make commands. They're documentation [here](https://gitlab.wikimedia.org/mhurd/mediawiki-docker-make).