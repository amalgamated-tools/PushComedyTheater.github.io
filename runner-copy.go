package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/devinterface/structomap"
)

type Parsed struct {
	StartStamp      int    `json:"start_stamp"`
	ID              string `json:"id"`
	Title           string `json:"title"`
	Date            string `json:"date"`
	Image           string `json:"image"`
	Cost            string `json:"cost"`
	PageUrl         string `json:"pageurl"`
	Description     string `json:"description"`
	FullDescription string `json:"full_description"`
	ParsedType      string `json:"type"`
	Slug            string `json:"slug"`
}

type CachedItems []struct {
	StartStamp      int    `json:"start_stamp"`
	ID              string `json:"id"`
	Title           string `json:"title"`
	Date            string `json:"date"`
	Image           string `json:"image"`
	Cost            string `json:"cost"`
	Pageurl         string `json:"pageurl"`
	Description     string `json:"description"`
	FullDescription string `json:"full_description"`
	Type            string `json:"type"`
	Slug            string `json:"slug"`
}

type AutoGenerated struct {
	Events []struct {
		StartStamp int `json:"start_stamp"`
	} `json:"events"`
	Images []struct {
		ID     string `json:"id"`
		URL160 string `json:"url_160"`
	} `json:"images"`
	Listing struct {
		Price           float64 `json:"price"`
		ID              string  `json:"id"`
		Title           string  `json:"title"`
		Free            bool    `json:"free"`
		SlugParam       string  `json:"slug_param"`
		Description     string  `json:"description"`
		DescriptionHTML string  `json:"description_html"`

		CoverPhotoID string `json:"cover_photo_id"`
	} `json:"listing"`
}
type portfolio struct {
	Data struct {
		Portfolio struct {
			Hosting []struct {
				ID                string `json:"id"`
				URL               string `json:"url"`
				FormattedDuration string `json:"formatted_duration"`
			} `json:"hosting"`
		} `json:"portfolio"`
	} `json:"data"`
}

var netClient = &http.Client{
	Timeout: time.Second * 10,
}
var CachedClasses CachedItems
var CachedShows CachedItems

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func main() {
	loadCache()
	loadAllEvents()
}

func loadCache() {
	fmt.Println("Loading cache")
	workspace := os.Getenv("GITHUB_WORKSPACE")
	cachedClassesFile := fmt.Sprintf("%s/cached_classes.json", workspace)
	cachedShowsFile := fmt.Sprintf("%s/cached_shows.json", workspace)

	fmt.Printf("-cached classes at %s\n", cachedClassesFile)
	fmt.Printf("-cached shows at %s\n", cachedShowsFile)
	cachedClasses, err := ioutil.ReadFile(fmt.Sprintf("%s/cached_classes.json", workspace))
	check(err)
	err = json.Unmarshal(cachedClasses, &CachedClasses)
	check(err)
	cachedShows, err := ioutil.ReadFile(fmt.Sprintf("%s/cached_shows.json", workspace))
	check(err)
	err = json.Unmarshal(cachedShows, &CachedShows)
	check(err)
}

func loadAllEvents() {
	body := loadURL("https://www.universe.com/users/push-comedy-theater-CT01HK/portfolio/current.json")

	var m portfolio

	err := json.Unmarshal(body, &m)

	if err != nil {
		panic(err)
	}

	events := make([]string, 0)

	for _, event := range m.Data.Portfolio.Hosting {
		print(event.ID)
		print("\n")
		eventDetail := loadEvent(event.ID, event.FormattedDuration)
		events = append(events, eventDetail)
	}

	f, err := os.Create("ohyeah.json")
	w := bufio.NewWriter(f)
	n4, err := w.WriteString(strings.Join(events, ","))
	fmt.Printf("wrote %d bytes\n", n4)
	w.Flush()

}

func loadEvent(id string, formattedDuration string) string {
	url := fmt.Sprintf("https://www.universe.com/api/v2/listings/%s.json", id)
	fmt.Printf("Loading url: %s\n", url)

	var m2 AutoGenerated

	body := loadURL(url)

	err := json.Unmarshal(body, &m2)
	if err != nil {
		panic(err)
	}

	coverPhotoID := m2.Listing.CoverPhotoID
	coverPhotoURL := ""
	for _, image := range m2.Images {
		if image.ID == coverPhotoID {
			coverPhotoURL = image.URL160
		}
	}

	cost, costString := 0.0, ""

	cost = m2.Listing.Price
	if cost == 0 {
		costString = "Free"
	} else {
		costString = fmt.Sprintf("$%.2f", cost)
	}

	a := Parsed{
		StartStamp:      m2.Events[0].StartStamp,
		ID:              m2.Listing.ID,
		Title:           m2.Listing.Title,
		Date:            formattedDuration,
		Image:           coverPhotoURL,
		Cost:            costString,
		PageUrl:         fmt.Sprintf("https://www.universe.com/events/%s", m2.Listing.SlugParam),
		Description:     m2.Listing.Description,
		FullDescription: m2.Listing.DescriptionHTML,
	}

	userSerializer := structomap.New().
		UseSnakeCase().
		Pick("StartStamp", "ID", "Title", "Date", "Image", "Cost", "PageUrl", "Description", "FullDescription")

	userMap := userSerializer.Transform(a)
	str, _ := json.MarshalIndent(userMap, "", "  ")

	output := unicode2utf8(string(str))
	return output
}

func loadURL(url string) []byte {
	response, _ := netClient.Get(url)
	body, err := ioutil.ReadAll(response.Body)
	if err != nil {
		panic(err)
	}
	return body

}

func unicode2utf8(source string) string {
	var res = []string{""}
	sUnicode := strings.Split(source, "\\u")
	var context = ""
	for _, v := range sUnicode {
		var additional = ""
		if len(v) < 1 {
			continue
		}
		if len(v) > 4 {
			rs := []rune(v)
			v = string(rs[:4])
			additional = string(rs[4:])
		}
		temp, err := strconv.ParseInt(v, 16, 32)
		if err != nil {
			context += v
		}
		context += fmt.Sprintf("%c", temp)
		context += additional
	}
	res = append(res, context)
	return strings.Join(res, "")
}
