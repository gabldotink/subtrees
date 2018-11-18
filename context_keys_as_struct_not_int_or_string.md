# Use struct{} and not int/string for context.Value() keys in Go

Code that details why we should use `struct{}` as context.Value() keys and not `int` or `string`. Open gist to see `main.go` but the TLDR is:

```Go
	type key struct{}
	return context.WithValue(ctx, key{}, "my value") // Set value
	myValue, ok := ctx.Value(key{}).(string) // Get value

```