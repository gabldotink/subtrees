package main

import (
	"testing"
)

// Why is type assertion so fast?
// https://old.reddit.com/r/golang/comments/9xs0r2/why_is_type_assertion_so_fast/

// go test -bench .

// BenchmarkStructMethod-12        200000000                6.10 ns/op
// BenchmarkInterface-12           200000000                7.43 ns/op
// BenchmarkTypeSwitch-12          200000000                7.14 ns/op
// BenchmarkTypeAssertion-12       200000000                6.53 ns/op 

type User interface {
	IncAge(i int)
}

type MyUser struct {
	Age int
}

func (u *MyUser) IncAge(i int) {
	u.Age = u.Age + i
}

func BenchmarkStructMethod(b *testing.B) {
	structMap := map[string]*MyUser{"user": &MyUser{}}
	structMethod(structMap, b.N)
}

func BenchmarkInterface(b *testing.B) {
	interfaceMap := map[string]User{"user": &MyUser{}}
	interfaceMethod(interfaceMap, b.N)
}

func BenchmarkTypeSwitch(b *testing.B) {
	emptyInterfaceMap := map[string]interface{}{"user": &MyUser{}}
	switchMethod(emptyInterfaceMap, b.N)
}

func BenchmarkTypeAssertion(b *testing.B) {
	emptyInterfaceMap := map[string]interface{}{"user": &MyUser{}}
	assertionMethod(emptyInterfaceMap, b.N)
}

func structMethod(u map[string]*MyUser, n int) {
	for k := 0; k < n; k++ {
		u["user"].IncAge(1)
	}
}

func interfaceMethod(u map[string]User, n int) {
	for k := 0; k < n; k++ {
		u["user"].IncAge(1)
	}
}

func switchMethod(u map[string]interface{}, n int) {
	for k := 0; k < n; k++ {
		switch v := u["user"].(type) {
		case *MyUser:
			v.IncAge(1)
		}
	}
}

func assertionMethod(u map[string]interface{}, n int) {
	for k := 0; k < n; k++ {
		if user, ok := u["user"].(*MyUser); ok {
			user.IncAge(1)
		}
	}
}
