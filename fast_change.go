package main

import (
    "bufio"
    "os"
	"fmt"
	"strings"
    "strconv"
)

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
	var ipts = strings.Split(ipt, ",")
	var laplus = -0.0016
	var loplus = -0.0062
	if len(ipts) >= 2 {
		la, _ := strconv.ParseFloat(ipts[0], 64)
		lo, _ := strconv.ParseFloat(ipts[1], 64)
		lastr := strconv.FormatFloat(la + laplus, 'f', 10, 64)
		lostr := strconv.FormatFloat(lo + loplus, 'f', 10, 64)
		var result = "<wpt lat='" + lastr + "' lon='" + lostr + "'></wpt>"
		fmt.Println(result);
		return true
	}
	return false
 }