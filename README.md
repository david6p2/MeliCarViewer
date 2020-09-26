# Meli Car Viewer
This is an app to test the Mercado Libre API. Especially the one related with cars.

![App Demo](https://github.com/david6p2/MeliCarViewer/blob/master/MeLiCarViewerDemo.gif)

## Architecture
It uses MVC but treating the ViewControllers also as Views to just show UI Elements and having Controllers to manage/format all the data that the Views/ViewControllers are going to show.

## Elements used

#### SearchViewController

| Screenshot | Description 
|---|---|
| ![SearchViewController](https://github.com/david6p2/MeliCarViewer/blob/master/SearchViewController.png) | - Custom TextFlied that use a Picker as input view to select the Porsche model to search for <br>- It works in portrait and landscape mode <br>- Use of custom Button <br>- Custom AlertViewController shown if no model is selected. This custom AlertViewController is also used to show errors in all the App <br>- This view was made using Storyboard |

#### CarResultsViewController

| Screenshot | Description 
|---|---|
| ![CarResultsViewController](https://github.com/david6p2/MeliCarViewer/blob/master/CarResultsViewController.png) | - CollectionViewController with Diffable Datasource and custom Layout <br>- SearchBar that filters the current results <br>- It works in portrait and landscape mode <br>- Formatted car price <br>- Use of custom labels <br>- Pagination <br>- Use of custom DataLoadingViewController when loading new pages of car results <br>- This view was made programmatically |

#### CarDetailViewController

| Screenshot | Description 
|---|---|
| ![CarDetailViewController](https://github.com/david6p2/MeliCarViewer/blob/master/CarDetailViewController.png) | - Scroll view to fit all the views in different Screens <br>- Created using Container View Controllers to solve having a masive View controller <br>- It works in portrait and landscape mode <br>- Use of stack views <br>- Use of custom labels <br>- All the car images are downloaded using a OperationQueue, but just the first is shown. In pending task we have a PagedViewController to show all the images <br>- Use of date formatter and currency formatter <br>- This view was made programmatically |

## Pending tasks
- Add more test to increase coverage
- Use a coordinator pattern to take the navigation outside of the ViewControllers
- Create a PagedViewController to show all the car images
- Use SwiftUI for the UI and Combine for use reactive programming
