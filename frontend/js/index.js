window.addEventListener('DOMContentLoaded', (event) =>{
    getVisitCount();
})

const functionApiUrl = ('https://w2tagdzwhj.execute-api.us-east-1.amazonaws.com/dev/count/');

const getVisitCount = () => {

    let count;  // Declare count within the scope of getVisitCount

    fetch(functionApiUrl)
        .then(response => {
            return response.json()

        }).then(response => {
            console.log("Website called API");
            count =  response.count;
            document.querySelector("#count").innerHTML = count;
            // document.getElementById("count").innerText = count;
        })
        .catch(function (error){
            console.log("Error: " + error);
        });
        return count;
}