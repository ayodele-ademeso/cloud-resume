window.addEventListener('DOMContentLoaded', (event) =>{
    getVisitCount();
})

var functionApiUrl = ('https://euxxn8zvn9.execute-api.us-east-1.amazonaws.com/prod/count/');

var getVisitCount = () => {

    fetch(functionApiUrl)
        .then(response => {
            return response.json()

        }).then(response => {
            console.log("Visitor Count: " + response.body);
            count =  response.body;
            document.querySelector("#count").innerHTML = count;
            // document.getElementById("count").innerText = count;
        })
        .catch(function (error){
            console.log("Error: " + error);
        });
        return count;
}