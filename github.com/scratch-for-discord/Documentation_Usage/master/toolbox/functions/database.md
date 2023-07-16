# Database

Databases are used to keep your values after your bot has been rebooted.

unlike [variables](variables/ "mention"), databases will keep it.

## JSON

use this for "start" if you don´t understand any other, the most easiest database

### Creating a new database

<figure><img src="../../.gitbook/assets/screenshot - 2022-10-24T132311.214.png" alt=""><figcaption><p>Use this block to create a new database file</p></figcaption></figure>

### Informations

<figure><img src="../../.gitbook/assets/screenshot - 2022-10-24T132543.850.png" alt=""><figcaption></figcaption></figure>

Output will be "world" because you previously set it in the database

### Management

<figure><img src="../../.gitbook/assets/screenshot - 2022-10-24T132745.032.png" alt=""><figcaption><p>Example of managing a database, first check if the value either exists or is in NUMBERS, if not define it to 0</p></figcaption></figure>

### How to store money for different users?

<figure><img src="../../.gitbook/assets/screenshot - 2022-10-24T132955.023.png" alt=""><figcaption><p>Example of giving message user point for every message</p></figcaption></figure>

## MongoDB

Works the same as JSON database, just you must create an account at [https://www.mongodb.com/](https://www.mongodb.com/)

1. Create an account
2. Create a new cluster "shared"
3. That is free up to 500 MB of data
4. click on connect&#x20;
5. connect your application
6.  copy the text

    <figure><img src="../../.gitbook/assets/image (3).png" alt=""><figcaption></figcaption></figure>
7. change your username and password
8. go to security / network access and add IP 0.0.0.0/0
9.  add your link to the connect to mongoDB block

    <figure><img src="../../.gitbook/assets/screenshot - 2022-10-24T133102.500.png" alt=""><figcaption></figcaption></figure>
10. Install the plugin by running                                                                                                         `npm i git+`[`https://github.com/ahqsoftwares/quickmongo.git`](https://github.com/ahqsoftwares/quickmongo.git) in the shell, and you are done!

## SQLite

Basic Database that is used the most and everywhere.

works the same as JSON or MongoDB



## Replit

Database made specially for Replit.com

It has less functions, but it exists.&#x20;

you can only get, set and delete, so I have no idea why to use this one...
