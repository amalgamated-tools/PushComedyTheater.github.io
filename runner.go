package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"time"
)

type Parsed struct {
	startStamp      int
	id              string
	title           string
	date            string
	image           string
	cost            string
	pageurl         string
	description     string
	fullDescription string
	parsedType      string
	slug            string
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
	// loadAllEvents()
}

func loadCache() {
	workspace := os.Getenv("GITHUB_WORKSPACE")
	cachedClasses, err := ioutil.ReadFile(fmt.Sprintf("%s/cached_classes.json", workspace))
	check(err)
	err = json.Unmarshal(cachedClasses, &CachedClasses)
	check(err)

	cachedShows, err := ioutil.ReadFile(fmt.Sprintf("%s/cached_shows.json", workspace))
	check(err)
	err = json.Unmarshal(cachedShows, &CachedShows)
	check(err)

	print(len(CachedClasses))
	print("\n")
	print(len(CachedShows))
}

func loadAllEvents() {
	body := loadURL("https://www.universe.com/users/push-comedy-theater-CT01HK/portfolio/current.json")

	var m portfolio

	err := json.Unmarshal(body, &m)

	if err != nil {
		panic(err)
	}

	event := m.Data.Portfolio.Hosting[0]
	print(event.ID)
	loadEvent(event.ID, event.FormattedDuration)

	// for _, event := range m.Data.Portfolio.Hosting {
	// 	print(event.ID)
	// 	print("\n")
	// 	loadEvent(event.ID)
	// }

}

func loadEvent(id string, formattedDuration string) []byte {
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
		startStamp:      m2.Events[0].StartStamp,
		id:              m2.Listing.ID,
		title:           m2.Listing.Title,
		date:            formattedDuration,
		image:           coverPhotoURL,
		cost:            costString,
		pageurl:         fmt.Sprintf("https://www.universe.com/events/%s", m2.Listing.SlugParam),
		description:     m2.Listing.Description,
		fullDescription: m2.Listing.DescriptionHTML,
	}
	fmt.Printf("%v\n", a)
	return body
}

func loadURL(url string) []byte {
	response, _ := netClient.Get(url)
	body, err := ioutil.ReadAll(response.Body)
	if err != nil {
		panic(err)
	}
	return body
}
