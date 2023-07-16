# If logic

## If statements

If statement is a function that checks if the value meets the condition. If statements are based on Booleans (true & false). This is used literally everywhere, to tell your code what to do.

![](<../../../.gitbook/assets/image (10).png>)

### Here is a good way to use if statements

```javascript
var velocity = 200
var player.x = 200
var player.y = 200

function up(){
 var velocity += 1
 var speed =  player.x + velocity
}
// checking if velocity has reached a value of 210
if (velocity = 210){
 // then we are going to reset their velocity
 var velocity = 200
 
}

```

The above code, specifies 3 variables velocity - players x position - and players  y position

We have created a function Functions that changes the velocity by 1 every time the player moves the in-game character, then creates a variable speed that adds the two variables player. x and the player's velocity which makes the player's movement less choppy.

Then we stated if velocity = 210 I want you to reset it because if we let velocity go up then the game will be unplayable

<figure><img src="../../../.gitbook/assets/screenshot (85).png" alt=""><figcaption><p>Example of using If function</p></figcaption></figure>

Just like the code snippet above this if statement asks if the value is = to a condition, in our case we have a message event that has an if statement, and asks if the value is = to  the condition and if that is True then the bot shall respond with Peter Duh.

{% hint style="info" %}
Word of advice please do not use if statements more than 5 times in one command they can and will slow your  bot down, but also slow down scratch for discord so it is  recommended that you use [state-machines.md](state-machines.md "mention").
{% endhint %}

## Else & Else if Statements

Else statements are simply a return, if the value is equal to condition then do, else value is not equal to the condition return as false.  Here is an example

```javascript
let person = 1

if(person == 1){
  console.log('Person is 1')
}
else {
 console.log('Person is not 1')
}
```

An example of a else statement in Scratch For Discord

<figure><img src="../../../.gitbook/assets/screenshot (86).png" alt=""><figcaption><p>Example to use if and else</p></figcaption></figure>

The first if statement validates if their message content is true, if it is then it further validates if their id is equal to the needed Id in order to run this command, If it is true then it returns Peter Duh, else it is not then it responds with Sorry you do not have access to this command.



Else if statements are the same but with further definition

```javascript
let x = 200
let y = 200
let velocity = 200

if (x == y){
 velocity +=1
 x += 200
 console.log(velocity)
}
else if (x > y){
 x - y + velocity
 console.log("User velocity: " + velocity + "User position" + x + y )
}

```

### Example of How to use else if statements in Scratch For Discord.

<figure><img src="../../../.gitbook/assets/screenshot (87).png" alt=""><figcaption></figcaption></figure>

Basically x = 1 and y = 0 if x is greater than y, print success message, else print x is too low.&#x20;
