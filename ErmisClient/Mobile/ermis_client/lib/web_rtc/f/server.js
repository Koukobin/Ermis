const express = require("express");
const https = require("https");
const socketIo = require("socket.io");
const fs = require("fs");

const app = express();

// Read in your certificate and key files
const options = {
  key: fs.readFileSync("/opt/ermis-server/certificate/server.key"),
  cert: fs.readFileSync("/opt/ermis-server/certificate/server.crt")
};

const server = https.createServer(options, app);
const io = socketIo(server);

app.use(express.static("public")); // Serve static files

io.on("connection", (socket) => {
  console.log("New user connected");

  socket.on("offer", (data) => {
    socket.broadcast.emit("offer", data);
  });

  socket.on("answer", (data) => {
    socket.broadcast.emit("answer", data);
  });

  socket.on("candidate", (data) => {
    socket.broadcast.emit("candidate", data);
  });
});

// Bind to the specific IP instead of the default localhost.
server.listen(9999, "192.168.10.103", () => {
  console.log("Secure Server running on https://192.168.10.103:9999");
});
