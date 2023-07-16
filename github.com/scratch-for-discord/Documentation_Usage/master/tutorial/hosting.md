---
description: How to host my bot?
---

# Hosting

Once you have both Blocks and Your bot prepared, you are ready for hosting

## Testing

For only testing your new command if it´s working, you can use build in hosting, you can find this in the Web app on right-side of navigation bar next to settings button.

<figure><img src="../.gitbook/assets/screenshot (39) (1).png" alt=""><figcaption><p>Use this block in <a href="../toolbox/base.md">BASE </a>category</p></figcaption></figure>

This is the token you use from step 7. of [bot.md](bot.md "mention")

## Hosting

You already made some working application and want to host it? Sure

You can use Many websites providing free hosting

One of the user friendly and basic one is [replit.com](https://replit.com/)&#x20;

or you can use websites like [railway ](https://railway.app/)or [heroku](https://www.heroku.com/)



### Hosting on Replit

1. Create a new Repl
2. Select Language as Node.js & name it whatever you want
3. Here you put All of your exported files, export is not the .s4d file

{% file src="../.gitbook/assets/test_bot.zip" %}
You can use this if you want
{% endfile %}

4\. Make sure to put all files from the folder and you are done. You can now run your bot!

{% hint style="danger" %}
If a bot's repository is on a [repl.it](https://replit.com/) free plan, your code is forced to be open-source

> If you don't use [[#process.env](hosting.md#process.env "mention")](hosting.md#process.env), your token is usable by anyone, read [#negligence](hosting.md#negligence "mention") if you don´t want to use them
{% endhint %}

### process.env

Secrets are [environment variables (`.env`)](https://en.wikipedia.org/wiki/Environment\_variable) and they are unvisible to others.

<figure><img src="../.gitbook/assets/EEEEEEEEEEEEEEEE.png" alt=""><figcaption><p>Example how to use environmental variables on replit</p></figcaption></figure>

{% hint style="success" %}
Congrats you have safely stored your token and are ready to continue coding!
{% endhint %}

### Possible Repercussions of Security Negligence <a href="#negligence" id="negligence"></a>

{% hint style="danger" %}
* Spy listening on the bot's reading data
  * Security negligence about sensitive user data is illegal in the EU
* Malicious usage of the bot
  * Nuke of every server the bot is in
  * Making the bot and the bot's account owner permanently banned from Discord
{% endhint %}
