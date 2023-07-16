# Lists

## What are lists?

Lists = Arrays&#x20;

An _array_ is a container object that holds a number of values of a single type. Each item in an array is called an _element_, and each element is accessed by its numerical _index_. As shown in the preceding illustration, numbering begins with 1 (in normal codes it starts with 0).

Lists are used mainly for splitting and managing a text

## Creating a list

You can make a list by splitting a text seen as example bellow, Creating an empty list or Making a list with same items by x times.

<figure><img src="../../.gitbook/assets/screenshot (48) (1).png" alt=""><figcaption><p>Example of a list</p></figcaption></figure>

{% code title="Output" %}
```javascript
[ 'A', 'B', 'CD', 'E', 'FG', 'H' ]
// 1    2     3    4     5    6 (POSITIONS)
```
{% endcode %}

## Managing a list

<figure><img src="../../.gitbook/assets/screenshot (74) (1).png" alt=""><figcaption></figcaption></figure>

{% code title="Output" %}
```javascript
[ 'Z', 'B',  'CD', 'E', 'FG', 'H', 'X' ]
/* Changed FIRST position to "Z", push = add to last position "X"*/
```
{% endcode %}

## Information of a list

<figure><img src="../../.gitbook/assets/screenshot (73) (1).png" alt=""><figcaption></figcaption></figure>

<pre class="language-javascript" data-title="Output"><code class="lang-javascript">6 //lenght
true // list contains "A"
1 //First position of Item "A"
<strong>CD //get item number 3
</strong>E,FG,H //get sub-list from 4 to last</code></pre>

## RegEx

A regular expression is a sequence of characters that specifies a search pattern in text. Usually such patterns are used by string-searching algorithms for "find" or "find and replace" operations on strings, or for input validation.

To make a Regex, you can use [https://regex101.com/](https://regex101.com/)

<figure><img src="../../.gitbook/assets/screenshot (47) (3).png" alt=""><figcaption><p>Example of using Regex</p></figcaption></figure>

{% code title="Output" %}
```javascript
['def']
/*This RegEx will get everything that is inside of brackets [], for multiple brackets
it will be as next output in a list ['def', 'etc']
```
{% endcode %}

### How to RegEx

1. You set OUTPUT to variable to be able to use it later, you can save "Create new RegEx of" to variable too to use it multiple times.
2. Now you have output you can do whatever you want.
3. lenght of matches = how many matches exists on given text, output is in lists
