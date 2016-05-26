package main

import (
	// "encoding/json"
	// "fmt"
	"io"
	"net/http"
	"net/http/httptest"
	// "reflect"
	"strings"
	"testing"
)

var (
	server *httptest.Server
	reader io.Reader
	input  string
)

func test(t *testing.T) {
	userJson := `{"Name": "test", "commitish": "master"}`

	reader := strings.NewReader(userJson) //Convert string to reader

	request, err := generateRelease("POST", input, reader) //Create request with JSON body

	res, err := http.DefaultClient.Do(request)

	if err != nil {
		t.Error(err) //Something is wrong while sending request
	}

	if res.StatusCode != 201 {
		t.Errorf("Success expected: %d", res.StatusCode) //Uh-oh this means our test failed
	}
}

// func testrepositoriesservice_createrelease(t *testing.T) {
//	setup()
//	defer server.close()

//	input := &release{name: string("v1.0")}

//	mux.handlefunc("/repos/o/r/releases", func(w http.responsewriter, r *http.request) {
//		v := new(release)
//		json.newdecoder(r.body).decode(v)

//		testmethod(t, r, "post")
//		if !reflect.deepequal(v, input) {
//			t.errorf("request body = %+v, want %+v", v, input)
//		}
//		fmt.fprint(w, `{"id":1}`)
//	})

//	release, _, err := githubpostrequest("o", "r", input)
//	if err != nil {
//		t.errorf("repositories.createrelease returned error: %v", err)
//	}

//	want := &release{name: string("test")}
//	if !reflect.deepequal(release, want) {
//		t.errorf("repositories.createrelease returned %+v, want %+v", release, want)
//	}
// }

// func testmethod(t *testing.t, r *http.request, want string) {
//	if got := r.method; got != want {
//		t.errorf("request method: %v, want %v", got, want)
//	}
// }

// var (
//	// mux is the HTTP request multiplexer used with the test server.
//	mux *http.ServeMux

//	// client is the GitHub client being tested.
//	client = http.Client{}
//	// server is a test HTTP server used to provide mock API responses.
//	server *httptest.Server
// )

// func setup() {
//	// test server
//	mux = http.NewServeMux()
//	server = httptest.NewServer(mux)

//	// github client configured to use test server
//	client = http.Client{}
//	url, _ := url.Parse(server.URL)
//	client.BaseURL = url
//	client.UploadURL = url
// }
