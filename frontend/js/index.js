var counterContainer = document.querySelector(".website-counter");
var resetButton = document.querySelector("#reset") //to be removed later
var visitCount = localStorage.getItem("page-view");

if (visitCount) {
    visitCount = Number(visitCount) + 1;
    //update local storage value
    localStorage.setItem("page-view", visitCount)
} else {
    visitCount = 1;
    //Add entry for key="page-view"
    localStorage.setItem("page-view", 1);
}

//display visitor count on web page
counterContainer.innerHTML = visitCount;

//Adding onClick even listener, to be removed later
resetButton.addEventListener("click", () => {
    visitCount = 1;
    localStorage.setItem("page-view", 1);
    counterContainer.innerHTML = visitCount;
});








