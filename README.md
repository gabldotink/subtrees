Quickly spin up a MediaWiki instance.

## Installation 

Clone the repo:

    git clone https://gitlab.wikimedia.org/mhurd/mediawiki-docker-make.git

## Usage

Switch to the `mediawiki-docker-make` directory:

    cd ~/mediawiki-docker-make

Now you can spin up the MediaWiki with the *make* command:
-   ```
    make
     ```
    Fetches the latest MediaWiki (into `~/mediawiki-docker-make/mediawiki/`) and spins up a Docker container using it

You can stop, start, restart or remove the containers with these commands:
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
    make remove
     ```
    Stops and removes mediawiki containers and files

Get quick Bash shell access to running containers with these commands:
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

Quickly switch skins with these commands (easy to add more if needed):

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