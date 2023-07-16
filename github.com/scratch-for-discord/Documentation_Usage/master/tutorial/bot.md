---
description: Application Creation and Management
---

# Bot Setup

## Application Creation

1. Go to the [Discord developer portal](https://discord.com/developers/applications)
2.  Click on on the top right button "New Application"

    <figure><img src="../.gitbook/assets/image (8).png" alt=""><figcaption><p>Discord Developer Portal﹣"New Application" Button</p></figcaption></figure>
3.  In the modal, input a name in the "name" field, then click on the button "create"

    <figure><img src="../.gitbook/assets/Screen Shot 2022-10-16 at 9.38.57 AM.png" alt="Discord Developer Portal﹣&#x22;Create an Application&#x22; Modal"><figcaption><p>Discord Developer Portal﹣"Create an Application" Modal</p></figcaption></figure>

## Application Customization

On the left, there is a sidebar menu which has an option "General Information"\
This is where you can customize the bot and add more information

<figure><img src="../.gitbook/assets/Screen Shot 2022-10-16 at 9.52.51 AM.png" alt="Discord Developer Portal﹣&#x22;General Information&#x22; Menu"><figcaption><p>Discord Developer Portal﹣"General Information" Menu</p></figcaption></figure>

## Bot Creation

1.  Click on the menu "Bot"

    <figure><img src="../.gitbook/assets/Screen Shot 2022-10-16 at 9.59.48 AM.png" alt="Discord Developer Portal﹣&#x22;Bot&#x22; Menu"><figcaption><p>Discord Developer Portal﹣"Bot" Menu</p></figcaption></figure>
2.  Click on the far right button "Add Bot"

    <figure><img src="../.gitbook/assets/image (23).png" alt="Discord Developer Portal﹣&#x22;Add Bot&#x22; Button"><figcaption><p>Discord Developer Portal﹣"Add Bot" Button</p></figcaption></figure>
3.  Scroll down to the sections "Privileged Gateway Intents", and turn all of them on

    <figure><img src="../.gitbook/assets/Screen Shot 2022-10-16 at 10.05.23 AM.png" alt="Discord Developer Portal﹣&#x22;Privileged Gateway Intents&#x22; Section"><figcaption><p>Discord Developer Portal﹣"Privileged Gateway Intents" Section</p></figcaption></figure>

{% hint style="warning" %}
### Requirement

Scratch for Discord does only work with all Privileged Gateway Intents allowed:

* PRESENCE INTENT
* SERVER MEMBERS INTENT
* MESSAGE CONTENT INTENT
{% endhint %}

{% hint style="danger" %}
### Limitations

Once a bot exceeds 100 servers:

* An official verification from Discord is needed
{% endhint %}

## Get the Token

1.  Get the token by clicking on the button "Reset Token", then click on the button "Copy"

    <figure><img src="../.gitbook/assets/Screen Shot 2022-10-16 at 10.26.06 AM.png" alt="Discord Developer Portal﹣&#x22;Token&#x22; Page"><figcaption><p>Discord Developer Portal﹣"Token" Page</p></figcaption></figure>

{% hint style="warning" %}
It is impossible to get an already created [token](../toolbox/base.md#token):\
If you have lost it, you need to reset it
{% endhint %}

{% hint style="info" %}
To know how to use the [token](../toolbox/base.md#token), check [#token](../toolbox/base.md#token "mention")
{% endhint %}

## Bot Invitation

1.  Go to the sidebar menu "OAuth2", then on the sub-menu "URL generator"

    <figure><img src="../.gitbook/assets/image (22).png" alt=""><figcaption></figcaption></figure>
2.  Select the option "bot"

    <figure><img src="../.gitbook/assets/Screen Shot 2022-10-16 at 10.58.43 AM.png" alt=""><figcaption><p>once selected another menu will open</p></figcaption></figure>
3.  Select the bot permissions you need _(recommandation: for a private bot, chose Administrator)_

    <figure><img src="../.gitbook/assets/Screen Shot 2022-10-16 at 11.01.34 AM.png" alt=""><figcaption></figcaption></figure>
4. Below the permissions menu, browse to the URL
5. Invite the bot to the server you need

{% hint style="info" %}
Further information and official documentation:\
[https://discordjs.guide/preparations/setting-up-a-bot-application.html#creating-your-bot](https://discordjs.guide/preparations/setting-up-a-bot-application.html#creating-your-bot)
{% endhint %}
