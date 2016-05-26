package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	//"net/url"
	"reflect"
	"testing"
)

var (
	// mux is the HTTP request multiplexer used with the test server.
	mux *http.ServeMux

	// client is the GitHub client being tested.
	client *Release

	// server is a test HTTP server used to provide mock API responses.
	server *httptest.Server
)

func NewClient(httpClient *http.Client) *Release {
	if httpClient == nil {
		httpClient = http.DefaultClient
	}

	return nil
}

func setup() {
	// test server
	mux = http.NewServeMux()
	server = httptest.NewServer(mux)

	// github client configured to use test server
	client = NewClient(nil)
	//url, _ := url.Parse(server.URL)
	//	client.BaseURL = url
	//client.UploadURL = url
}

func testMethod(t *testing.T, r *http.Request, want string) {
	if got := r.Method; got != want {
		t.Errorf("Request method: %v, want %v", got, want)
	}
}

func TestRepositoriesService_CreateRelease(t *testing.T) {
	setup()
	defer server.Close()

	input := &Release{Name: "v1.0"}

	mux.HandleFunc("/repos/o/r/releases", func(w http.ResponseWriter, r *http.Request) {
		v := new(Release)
		json.NewDecoder(r.Body).Decode(v)

		testMethod(t, r, "POST")
		if !reflect.DeepEqual(v, input) {
			t.Errorf("Request body = %+v, want %+v", v, input)
		}
		fmt.Fprint(w, `{"id":1}`)
	})

	// release, _, err := client.generateRelease("o", "r", input)
	// if err != nil {
	//	t.Errorf("Repositories.CreateRelease returned error: %v", err)
	// }

	// want := &RepositoryRelease{ID: Int(1)}
	// if !reflect.DeepEqual(release, want) {
	//	t.Errorf("Repositories.CreateRelease returned %+v, want %+v", release, want)
	// }
}
