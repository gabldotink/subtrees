# State Machines

Switch cases can have multiple conditions at once, they are typically faster than if and else statements because instead of checking if the statement meets the condition.  It just decides which case must be completed.

For example

```javascript
const pet = "dog";
 
switch (pet) {
  case "lizard":
    console.log("I own a lizard");
    break;
  case "dog":
    console.log("I own a dog");
    break;
  case "cat":
    console.log("I own a cat");
    break;
  case "snake":
    console.log("I own a snake");
    break;
  case "parrot":
    console.log("I own a parrot");
    break;
  default:
    console.log("I don't own a pet");
    break;
}
```

Switch cases are like [if-logic.md](if-logic.md "mention") statements, above checks what pet is equal to, then validates it with case - so in this case pet is  = dog and switch will run through it all until it finds that value then breaks and won´t check any other cases. Switch can only be ONE value and you can´t compare values, for that you should use basic logic.

We can do the same inside of scratch for discord - Here is an example

<figure><img src="../../../.gitbook/assets/image (13).png" alt=""><figcaption></figcaption></figure>

Just like above this switch case checks the variable then checks values until it finds the value then run the code inside it.

## Why use switch cases?

The reason you may want to use it is that with a lot of if statements come poor optimization, In scratch for discord it can lag a lot when you have more than 10 if statements in a single command. Not only does it lag scratch for discord but it also creates problems for users who use your bot.

When multiple users use the same command, it has to run through each if statement just to get the value and then validate that it meets the value specified, but if you use switch cases you can check all the values at once and then break the loop when it is found thus making it faster.

Why? It is faster, cleaner, easily manageable&#x20;
