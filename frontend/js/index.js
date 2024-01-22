window.addEventListener('DOMContentLoaded', (event) =>{
    getVisitCount();
})

const functionApiUrl = ('https://w2tagdzwhj.execute-api.us-east-1.amazonaws.com/dev/count/');

const getVisitCount = () => {


    fetch(functionApiUrl)
        .then(response => {
            return response.json()

        }).then(response => {
            console.log("Website called API");
            const count = JSON.parse(response).count;
            document.getElementById("count").innerText = count;
        })
        .catch(function (error){
            console.log("Error: " + error);
        });
        return count;
}

// window.addEventListener('DOMContentLoaded', () => {
//     getVisitCount();
// });

// const functionApiUrl = 'https://w2tagdzwhj.execute-api.us-east-1.amazonaws.com/dev/count/';

// const getVisitCount = () => {
//     fetch(functionApiUrl)
//         .then(response => {
//             return response.json();
//         })
//         .then(response => {
//             console.log("Website called API");

//             const count = JSON.parse(response)["count"];
//             console.log("Count Value:", count);

//             document.addEventListener('DOMContentLoaded', () => {
//                 const countElement = document.querySelector("#count");
//                 console.log("Count Element:", countElement);

//                 if (countElement) {
//                     countElement.innerText = countValue;
//                 } else {
//                     console.error("Element with id 'count' not found");
//                 }
//             });
//         })
//         .catch(error => {
//             console.log("Error: " + error);
//         });
// };



