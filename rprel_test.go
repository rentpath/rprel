package main

// import (
//	"encoding/json"
//	"fmt"
//	"io"
//	"net/http"
//	"net/http/httptest"
//	"reflect"
//	"strings"
//	"testing"
// )

// var (
//	server *httptest.Server
//	reader io.Reader
//	input  []byte
// )

// func test(t *testing.T) {
//	userJson := `{"Name": "test", "commitish": "master"}`

//	reader := strings.NewReader(userJson)

//	request, err := githubPostRequest("POST", input, reader)

//	res, err := http.DefaultClient.Do(request)

//	if err != nil {
//		t.Error(err)
//	}

//	if res.StatusCode != 201 {
//		t.Errorf("Success expected: %d", res.StatusCode)
//	}
// }
