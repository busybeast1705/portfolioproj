var express = require('express');
var app = express();
var bodyParser = require("body-parser");
app.set("view engine","ejs");
app.use(bodyParser.urlencoded({extended: true}));
app.use(express.static(__dirname+"/public"));
var mysql =require('mysql');
var connection = mysql.createConnection({
   host     : 'localhost',
  user     : 'root',
  database : 'join_us'
});

app.post('/register', function(req,res){
 var person = {email: req.body.email};
 connection.query('INSERT INTO users SET ?', person, function(err, result) {
 console.log(err);
 console.log(result);
 res.redirect("/");
 });
});


app.get("/", function(req, res){
  var q = "SELECT COUNT(*) AS count FROM users";
 connection.query(q, function (error, results) {
 var count = "We have " + results[0].count + " users";
	 if (error) throw error;
	
// res.send(msg);
	 res.render("home",{data:count});
 });
});
 
// app.get("/joke", function(req, res){
//  var joke = "<strong>What do you call a dog that does magic tricks?<\strong><em> A labracadabrador.<\em>";
//  res.send(joke);
// });

// app.get("/random_num", function(req, res){
//  var num = Math.floor((Math.random() * 10) + 1);
//  res.send("Your lucky number is " + num);
// });

app.listen(3000, function () {
 console.log('App listening on port 3000!');
});

