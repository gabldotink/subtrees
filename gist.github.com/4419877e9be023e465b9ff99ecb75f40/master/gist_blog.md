# Blogging with Gist

Gist simplicity can turn blogging into a liberating experience.

**Pros**|**Cons**
:-----|:-----
✅ Free, simple, fast, hassle-free|❌ Image upload in comments only
✅ Tagging|❌ No post pinning
✅ Search|❌ Doesn't look like a blog
✅ Revisions|❌ Unfriendly URLs
✅ Comments|❌ Cannot disable comments
✅ Delete comments|❌ Date only shown in Revisions
✅ Markdown|❌ Not WYSIWYG
✅ Syntax highlighting|❌ No fancy theme
✅ One click copy (Fork)|
✅ `git clone` gist URL|
✅ Not Wordpress, not Medium|
✅ No ads|
✅ No facebook/google tracking|
✅ Reliable, secure, accessible|

## How it works

A Gist post is a collection of one or more files. To use it as a blog, simply create a markdown (.md) file for each post and you're set.

If you're like me who also use Gist to share non non-blogging content, simply append `#blog` to blog Gist titles. Doing so allows us to search blog posts: [`user:ww9 #blog`](https://gist.github.com/search?utf8=%E2%9C%93&q=user%3Aww9+%23blog)

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

Users can upload images in comments simply copying and pasting the image using CTRL+V. Drag-n-Drop works as well. I guess this wont work on mobile phones.

You can delete any comment from your gists.

## Tips

- Multiple files in a post are listed in alphabetical order. To make a file appear first on the list, prepend its name with a space. To make it appear last, prepend filename with `~`. Numbers also work.

## Tools

**Tool**|**Notes**
:-----|:-----
[GitHub Flavored Markdown Spec](https://github.github.com/gfm/)|Comprehensive
[Stackedit - online markdown editor](https://stackedit.io)|Feature rich with live preview. Publishes to Github (haven't tested).
[Minimalist Online Markdown Editor](http://markdown.pioul.fr/)|Fast with live preview.

## Formatting with Markdown

See my other gist called [Gist Markdown Examples](https://gist.github.com/ww9/44f08d44327a40d2ab309a349bebec57) for ways to format posts in Gist.

**Happy blogging!**