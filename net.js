const brain = require("brain.js")
const fs = require('fs')
var express = require('express');
var app = express();

const config = {
  hiddenLayers: [5],
  activation: 'sigmoid', // supported activation types: ['sigmoid', 'relu', 'leaky-relu', 'tanh'],
  learningRate: 0.1
};

const net = new brain.NeuralNetwork(config)


function train2(){
  fs.readFile("C:\\Users\\Owner\\AppData\\Roaming\\EiuNDcMuKwIRKrPXEsTrJreP\\vFYfAogessHCds\\accuracy_output3_mapped.txt", "utf8", (err, data) => {
    if (err) {
      console.error(err)
      return
    }
  
      net.train(JSON.parse(data)  ,{
          iterations: 5000,
          errorThresh: 0.00005, 
          log: true, 
      
      })
})
}
train2()
  

var accuracy = 1
var time_too_three_shots_hit = 0.025
var fired = 3


app.get("/set", function(req, res){
  time_too_three_shots_hit = req.query.time_too_three_shots_hit
  fired = req.query.fired
  accuracy = req.query.accuracy

  console.log("accuracy", accuracy)
  console.log("Setting fired", fired)
  dist = req.query.dist
  const o = net.run(
    {dist: 0.2, fired: fired, accuracy: accuracy}
  )
  console.log(JSON.stringify(o))
  res.send("good")
})


app.get('/accuracy', function (req, res) {
  console.log(req.query.dist, 6969, fired)
  const o = net.run(
    {dist: req.query.dist, fired: fired, accuracy: accuracy}
  )

  res.send(JSON.stringify(o));
});


app.listen(3000, function(){
  console.log('Example app listening on port 3000!');
});
