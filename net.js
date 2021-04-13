const brain = require("brain.js")
const fs = require('fs')
let express = require('express');
let app = express();

const config = {
  hiddenLayers: [5],
  activation: 'sigmoid', // supported activation types: ['sigmoid', 'relu', 'leaky-relu', 'tanh'],
  learningRate: 0.1
};

const net = new brain.NeuralNetwork(config)

// IMPORTANT! Change the path below to the location of mapped_data.txt
// Don't forget to use two \\ between folders, just like shown below
const aimware_path = `C:\\Users\\Owner\\AppData\\Roaming\\EiuNDcMuKwIRKrPXEsTrJreP\\vFYfAogessHCds`


function train(){
    fs.readFile(aimware_path + "\\mapped_data.txt", "utf8", (err, data) => {
        if (err) {
            console.error(err)
            return
        }

        net.train(JSON.parse(data), {
            iterations: 20000,
            errorThresh: 0.00005, 
            log: true,
        })
    })
}

train()
  
let accuracy = 1
let fired = 3

app.get("/set", function(req, res){
    accuracy = req.query.accuracy
    dist = req.query.dist
    fired = req.query.fired
    res.send("good")
})

app.get('/accuracy', function (req, res) {
  const o = net.run({dist: req.query.dist, fired: fired, accuracy: accuracy})
  res.send(JSON.stringify(o));
});


app.listen(3000, function(){
  console.log('Example app listening on port 3000!');
});
