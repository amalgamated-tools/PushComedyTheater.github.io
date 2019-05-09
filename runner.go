package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	log "github.com/sirupsen/logrus"
)

type Portfolio struct {
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
type ParsedListing struct {
	StartStamp      int    `json:"start_stamp"`
	ID              string `json:"id"`
	Title           string `json:"title"`
	Date            string `json:"date"`
	Image           string `json:"image"`
	Cost            string `json:"cost"`
	PageURL         string `json:"pageurl"`
	Description     string `json:"description"`
	FullDescription string `json:"full_description"`
	Type            string `json:"type"`
	Slug            string `json:"slug"`
}

type Listing struct {
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

var netClient = &http.Client{
	Timeout: time.Second * 10,
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}

var CurrentClasses []ParsedListing
var CurrentShows []ParsedListing
var portfolio Portfolio
var currentClassesFile string
var currentShowsFile string

func loadCurrent() {
	workspace := os.Getenv("GITHUB_WORKSPACE")
	log.Info("Loading current files from %s", workspace)
	currentClassesFile := fmt.Sprintf("%s/current_classes.json", workspace)
	currentShowsFile := fmt.Sprintf("%s/current_shows.json", workspace)

	currentClasses, err := ioutil.ReadFile(currentClassesFile)
	check(err)
	err = json.Unmarshal(currentClasses, &CurrentClasses)
	check(err)
	log.Infof(" - Loaded %d current classes", len(CurrentClasses))

	currentShows, err := ioutil.ReadFile(currentShowsFile)
	check(err)
	err = json.Unmarshal(currentShows, &CurrentShows)
	check(err)
	log.Infof(" - Loaded %d current shows", len(CurrentShows))
}

func loadURL(url string) []byte {
	response, _ := netClient.Get(url)
	body, err := ioutil.ReadAll(response.Body)
	if err != nil {
		panic(err)
	}
	return body
}

func loadEvent(id string, formattedDuration string) ParsedListing {
	url := fmt.Sprintf("https://www.universe.com/api/v2/listings/%s.json", id)
	log.Infof("Loading url: %s\n", url)

	var event Listing

	body := loadURL(url)

	err := json.Unmarshal(body, &event)
	if err != nil {
		panic(err)
	}

	coverPhotoID := event.Listing.CoverPhotoID
	coverPhotoURL := ""
	for _, image := range event.Images {
		if image.ID == coverPhotoID {
			coverPhotoURL = image.URL160
		}
	}

	cost, costString := 0.0, ""

	cost = event.Listing.Price
	if cost == 0 {
		costString = "Free"
	} else {
		costString = fmt.Sprintf("$%.2f", cost)
	}
	return ParsedListing{
		StartStamp:      event.Events[0].StartStamp,
		ID:              event.Listing.ID,
		Title:           event.Listing.Title,
		Date:            formattedDuration,
		Image:           coverPhotoURL,
		Cost:            costString,
		PageURL:         fmt.Sprintf("https://www.universe.com/events/%s", event.Listing.SlugParam),
		Description:     event.Listing.Description,
		FullDescription: event.Listing.DescriptionHTML,
	}

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

func main() {
	log.SetFormatter(&log.TextFormatter{
		FullTimestamp: true,
	})
	loadCurrent()
	body := loadURL("https://www.universe.com/users/push-comedy-theater-CT01HK/portfolio/current.json")

	err := json.Unmarshal(body, &portfolio)

	if err != nil {
		panic(err)
	}

	events := make([]ParsedListing, 0)

	for _, event := range portfolio.Data.Portfolio.Hosting {
		events = append(events, loadEvent(event.ID, event.FormattedDuration))
	}

}
