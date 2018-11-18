# Why use struct{} and not int/string for context.Value() keys in Go

A small piece of code that details why we should use `struct{}` as context.Value() keys and not `int` or `string`. TLDR:
```Go
	type key struct{}
	return context.WithValue(ctx, key{}, "my value") // Set value
	myValue, ok := ctx.Value(key{}).(string) // Get value

```