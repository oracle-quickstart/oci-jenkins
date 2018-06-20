package test

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"testing"
)

func TestMasterSuccessful(t *testing.T) {
	url := "http://129.146.142.226:8989"

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		t.Fatal(err)
	}
	req.SetBasicAuth("admin", "ab6fb353611a45aeba882eedec796298")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}

	if resp.StatusCode != http.StatusOK {
		t.Errorf("expect status OK, but got %v", resp.Status)
	}

	defer resp.Body.Close()

}

func TestMasterPluginInstallaion(t *testing.T) {
	url := "http://129.146.142.226:8989"

	req, err := http.NewRequest("GET", url+"/pluginManager/api/json?depth=1&tree=plugins[shortName]", nil)
	if err != nil {
		t.Fatal(err)
	}
	req.SetBasicAuth("admin", "ab6fb353611a45aeba882eedec796298")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}

	if resp.StatusCode != http.StatusOK {
		t.Errorf("expect status OK, but got %v", resp.Status)
	} else {
    fmt.Printf("Jenkins Master is working, response status is %v\n", resp.Status)
  }

	body, readErr := ioutil.ReadAll(resp.Body)
	if readErr != nil {
		t.Fatal(readErr)
	}
	//var data interface{}

	var pluginJson PluginJson

	err = json.Unmarshal([]byte(body), &pluginJson)

	if err != nil {
		panic(err.Error())
	}
	fmt.Printf("Results: %v\n", pluginJson.Plugins)

	fmt.Println(len(pluginJson.Plugins))

  if containsPlugin("oracle-cloud-infrastructure-compute", pluginJson.Plugins) {
 		fmt.Printf("user plugin %v installed\n", "oracle-cloud-infrastructure-compute")
 	} else {
    t.Errorf("failed install plugin %v\n", "oracle-cloud-infrastructure-compute")
  }

	defer resp.Body.Close()

}

func containsPlugin(str string, plugins Plugins) bool {
	for _, v := range plugins {
		if v.ShortName == str {
			return true
		}
	}
	return false
}

type PluginJson struct {
	Class   string
	Plugins Plugins
}

type Plugins []struct {
  ShortName string
}
