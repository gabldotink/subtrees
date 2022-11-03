# Guidelines

## Drop-downs

### Export

#### **Problematic Behavior**

Though you can put the export code in the drop-down data array, it couldn't contain newlines (including ) without causing the drop-down option to not be saved correctly.

#### **Alternative**

Use

```js
switch (dropdown_value) {
  case (value1) :
    // first multiline export code
    break;
  case (value2) :
    // second multiline export code
    break;
  default :
    // error: missing export code
}
```
