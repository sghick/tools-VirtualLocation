package main

import (
    "bufio"
    "os"
	"fmt"
	"strings"
	// "strconv"
    "io/ioutil"
    "encoding/json"
	"net/http"
)

type Resp struct {
	Status int `json:"status"`
	Message string `json:"msg"`
	Count int `json:"count"`
	Locations []Location `json:"result"`
 }
   
type Location struct {
	Latitude string `json:"lat"`
	Longitude string `json:"lng"`
	Match string `json:"match"`
 }   

var _root string

func main() {
	GetInput()
 }

func ExportError(error string) {
	fmt.Println(error)
 }

func GetInput() {
	reader := bufio.NewReader(os.Stdin)
	for {
        fmt.Print("-> ")
        input, _ := reader.ReadString('\n')
        // 兼容Windows And Mac
		input = strings.Replace(input, "\n", "", -1)
        if BeginRun(input) == false {
			break
		}
	}
 }

func BeginRun(ipt string) bool {
	var oid = "10396"
	var key = "10254xu8uy49xv04uz22w65xuwxv29u0z68463"
	var url = "http://api.gpsspg.com/convert/coord/?oid=" + oid + "&key="+ key + "&from=3&to=1&output=json" + "&latlng=" + ipt
	httpResp, err := http.Get(url)
	if err != nil {
		fmt.Println(err)
		return false
	}
	defer httpResp.Body.Close()

	bodyContent, err := ioutil.ReadAll(httpResp.Body)
	if err != nil {
		fmt.Println(err)
		return false
	}
	resp := new(Resp)
	json.Unmarshal(bodyContent, resp)
	fmt.Println(resp)
	if (len(resp.Locations) <= 0) {
		fmt.Println("data empty")
		return false
	}

	latstr := resp.Locations[0].Latitude
	lonstr := resp.Locations[0].Longitude
	// latstr := strconv.FormatFloat(resp.Locations[0].Latitude, 'f', 10, 64)
	// lonstr := strconv.FormatFloat(resp.Locations[0].Longitude, 'f', 10, 64)
	var result = "<wpt lat='" + latstr + "' lon='" + lonstr + "'></wpt>"
	fmt.Println(result);
	return true
 }
