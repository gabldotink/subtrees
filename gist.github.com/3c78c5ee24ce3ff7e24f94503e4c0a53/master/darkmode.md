```
html[theme='dark-mode'] {
    filter: invert(1) hue-rotate(180deg);
}
```

The filter CSS property applies graphical effects like blur or color shift to an element. Filters are commonly used to adjust the rendering of images, backgrounds, and borders. (Reference: MDN Web Docs)

For this dark mode, we would be using two filters namely invert and hue-rotate

invert filter helps to invert the color scheme of the application. So, black becomes white and white becomes black and similarly for all the colors.invert() function as the value of the filter property will take the number from 0 to 1 or percentages from 0% to 100%

hue-rotate filter helps us with all the other colors that are not black and white. Rotating Hue by 180 degrees, we make sure the color theme of the application does not change but just attenuate the colors of it.
  
The only catch with this method is, it will also invert all the images, picture and video in your application. So we will add the same rule to all images to reverse the effect.
```
html[theme='dark-mode'] img,
picture,
video{
    filter: invert(1) hue-rotate(180deg);
}
```

and we will also add a class to reverse the effect form specific tag.

```
.invert {
    filter: invert(1) hue-rotate(180deg);
}
```
