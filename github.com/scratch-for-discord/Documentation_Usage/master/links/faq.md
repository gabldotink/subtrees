# ❔ FAQ

## Desktop and android app

Support for both of these was stopped. It was only that it runed the browser in the app and you should just use [https://scratch-for-discord.com/](https://scratch-for-discord.com/).

## How to Hide token in Replit?

{% content-ref url="../tutorial/hosting.md" %}
[hosting.md](../tutorial/hosting.md)
{% endcontent-ref %}

## My bot don´t want to go on

Make sure to follow everything in [bot.md](../tutorial/bot.md "mention") and [hosting.md](../tutorial/hosting.md "mention")

Try typing `kill 1` in shell

Try Forking the code to new replit

### Still don´t wanna go on?

Check if you are receiving any errors.

Most common error is `cannot find module [MODULE_NAME]` for this just run `npm i [MODULE_NAME]` in the shell.

## Hosting bot 24/7

<figure><img src="../.gitbook/assets/screenshot (95).png" alt=""><figcaption><p>Easiest way to host your bot</p></figcaption></figure>

1. go to [https://uptimerobot.com/](https://uptimerobot.com/)
2.  Add a new monitor with method Http(s)

    <figure><img src="../.gitbook/assets/image (1).png" alt=""><figcaption><p>Your bot link is a link of page it will create</p></figcaption></figure>
3. Your bot should stay alive!

## Exporting code not working

Open a Developer console and check for errors, you can open it by pressing F12

## Which host do I use?

You can Either use [https://replit.com/](https://replit.com/), [https://railway.app/](https://railway.app/), [https://client.dishost.xyz/](https://client.dishost.xyz/), [https://www.cyclic.sh/](https://www.cyclic.sh/)

## Unexpected token

Looks like you forgot to fill some value?

### Unexpected end of JSON input

There are missing brackets { or } in your .json file

### Unexpected string in JSON at position

You are missing a comma somewhere in your .json file

## Commands

### Kick & Ban

{% content-ref url="../toolbox/discord/servers/members/" %}
[members](../toolbox/discord/servers/members/)
{% endcontent-ref %}

### Specific Channel

{% content-ref url="../toolbox/discord/servers/channels/" %}
[channels](../toolbox/discord/servers/channels/)
{% endcontent-ref %}

### Making Slash reply ephemeral

Input to Ephemeral field TRUE - visible only to author, FALSE - Visible to anyone

### Where are forum blocks?

Discord.js Don´t allows us to make them.

### How to do Duration?

if you want something like 1m (1 min), 2h (2 hours)

You can do it using command handler (examples)

and then multiplying the value with seconds

### How to use custom Emojis?

Input their ID or for message:

non animated: <:ID:NAME>\
animated: \<a:ID:NAME>
