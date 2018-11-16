# Blogging with Gist

Gists as a blogging plaform can be a liberating experience.

**Pros**|**Cons**
:-----|:-----
✅ Images|❌ No fancy theme
✅ Tagging|❌ No post pinning
✅ Search|❌ Doesn't look like a blog
✅ Revisions|❌ Cannot disable comments
✅ Comments|❌ Unfriendly URLs
✅ Delete comments|❌ Date only shown in Revisions
✅ Markdown|❌ *Markdown*
✅ Syntax highlighting|
✅ One click copy (Fork)|
✅ `git clone` gist URL|
✅ Not Wordpress, not Medium|
✅ No ads, no facebook/google tracking|
✅ Free, simple, fast, hassle-free|
✅ Reliable, secure, accessible|

## How it works

A Gist is a collection of one or more files that are ordered by alphabetical order. To use it as a blog, simply create a markdown (.md) file for each post and you're set.

If you, like me, also use Gist for non non-blogging content, simply add `#blog` the the end of blog Gist title. Doing so allows us to search blog posts: [`user:ww9 #blog`](https://gist.github.com/search?utf8=%E2%9C%93&q=user%3Aww9+%23blog)

## Search

Filters that work in Gist search.

**Search**|**Gists**
:-----|:-----
stars:>100|with more than 100 stars
user:ww9|from user `ww9`
#blog|with `#blog` in title or content
NOT #misc|not containing `#misc` in title or content
extension:go|with `.go` files
forks:<200|with less than 200 forks
size:1000..4000|having a file between 1000kb and 4000kb
size:>4000|having a file larger than 4000kb

## Search examples

**Search**|**Result**
:-----|:-----
[#blog user:ww9](https://gist.github.com/search?utf8=%E2%9C%93&q=%23blog+user%3Aww9)|My blog posts
[stars:>100 extension:go](https://gist.github.com/search?utf8=%E2%9C%93&q=stars%3A%3E100+extension%3Ago&ref=searchresults)|.go gists with more than 100 stars

## Comments

Users can upload images in comments simply copying and pasting the image using CTRL+V. You can delete any comment from your gists.

## Tips

- Post with multiple files list them in alphabetical order. Start file name with space to have it appear first or `~` for last. Numbers also work.

## Tools

**Tool**|**Notes**
:-----|:-----
[GitHub Flavored Markdown Spec](https://github.github.com/gfm/)|Comprehensive
[Stackedit - online markdown editor](https://stackedit.io)|Feature rich with live preview. Publishes to Github (haven't tested).
[Minimalist Online Markdown Editor](http://markdown.pioul.fr/)|Fast with live preview.