Quickly spin up a MediaWiki instance.

## Installation 

Clone the repo:

    git clone https://gitlab.wikimedia.org/mhurd/mediawiki-docker-make.git

## Usage

Switch to the `mediawiki-docker-make` directory:

    cd ~/mediawiki-docker-make

Now you can spin up the MediaWiki with any of the following commands:

-   ```
    make
     ```
    Fetches the latest MediaWiki (into `~/mediawiki-docker-make/mediawiki/`) and spins up a Docker container using it
-   ```
    make remove
     ```
    Stops and removes mediawiki containers and files
-   ```
    make stop
     ```
    Stops mediawiki containers
-   ```
    make start
     ```
    Start mediawiki containers
-   ```
    make restart
     ```
    Restarts mediawiki containers
-   ```
    make bashmw
     ```
    Bash access to the mediawiki container
-   ```
    make bashjr
     ```
    Bash access to the job runner container
-   ```
    make bashwb
     ```
    Bash access to the web container

You can run these skin-related *make* commands **after** spinning up MediaWiki with one of the other *make* commands (more are added easily):

-   ```
    make usevectorskin
     ```
    Fetch and switch to the Vector skin
-   ```
    make usedarkvectorskin
     ```
    Fetch and switch to the dark Vector skin
-   ```
    make useminervaneueskin
     ```
    Fetch and switch to the Minerva Neue skin
-   ```
    make usetimelessskin
     ```
    Fetch and switch to the Timeless skin