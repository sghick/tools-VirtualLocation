package main

import (
    "bufio"
    "os"
	"fmt"
	"strings"
	"strconv"
    "io/ioutil"
    "encoding/json"
	"net/http"
	"./locationcoordinate2d"
)

type Resp struct {
	Status int `json:"status"`
	Locations []Location `json:"locations"`
 }
   
type Location struct {
	Latitude float64 `json:"lat"`
	Longitude float64 `json:"lng"`
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

}

func BeginRunFromServer(ipt string) bool {
	var key = "NWEBZ-UBAWQ-ZYX5R-GHVNF-2DPG2-OSFB7"
	var url = "https://apis.map.qq.com/ws/coord/v1/translate?locations=" + ipt + "&type=5&key="+ key
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
	if (len(resp.Locations) <= 0) {
		fmt.Println("data empty")
		return false
	}
	latstr := strconv.FormatFloat(resp.Locations[0].Latitude, 'f', 10, 64)
	lonstr := strconv.FormatFloat(resp.Locations[0].Longitude, 'f', 10, 64)
	var result = "<wpt lat='" + latstr + "' lon='" + lonstr + "'></wpt>"
	fmt.Println(result);
	return true
 }