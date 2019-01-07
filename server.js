// const express = require('express');
// const serveStatic = require('serve-static');
// const bodyParser = require('body-parser');
// const history = require('connect-history-api-fallback');

// const app = express();

// const port = process.env.PORT || 5000;
// // way to make router work with history
// app.use(serveStatic(__dirname + '/dist'));

// app.use(
//   history({
//     disableDotRule: true,
//     index: '/',
//   }),
// );

// app.get('*', function(req, res) {
//   res.sendFile(__dirname + '/dist/index.html');
// });

// app.use(bodyParser.urlencoded({ extended: true }));
// app.use(bodyParser.json());

// app.use(function(req, res, next) {
//   res.header('Access-Control-Allow-Origin', '*');
//   res.header(
//     'Access-Control-Allow-Headers',
//     'Origin, X-Requested-With, Content-Type, Accept',
//   );
//   next();
// });

// app.listen(port);

// console.log('server started ' + port);
