# Use struct{} as keys for context.Value() in Go

In the other file of this gist I detail why we should use `struct{}` as context.Value() keys and not `int` or `string`. **Open gist** to see `main.go` but the TLDR is:

```Go
	type key struct{}
	ctx = context.WithValue(ctx, key{}, "my value") // Set value
	myValue, ok := ctx.Value(key{}).(string) // Get value

```