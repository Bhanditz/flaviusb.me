http        = require 'http'
urls        = require 'url'
querystring = require 'querystring'
fs          = require 'fs'

jade = require 'jade'

fourohfour = (req, res, url) ->
  res.writeHeader 404, 'Content-Type': 'text/html'
  options = locals: { url: url }
  jade.renderFile __dirname + "/404.jade", options, (error, data) ->
    res.end data

threeohone = (req, res, url) ->
  res.writeHeader 301, 'Location': url , 'Content-Type': 'text/html'
  options = locals: { url: url }
  jade.renderFile __dirname + "/301.jade", options, (error, data) ->
    res.end data


index = (req, res) ->
  res.writeHeader 200, 'Content-Type': 'text/html'
  options = locals: {}
  jade.renderFile __dirname + "/index.jade", options, (error, data) ->
    res.write data
    res.end()

done = (req, res, url) ->
  res.writeHeader 200, 'Content-Type': 'text/html'
  options = locals: { url: url }
  jade.renderFile __dirname + "/done.jade", options, (error, data) ->
    res.write data
    res.end()

routes = {}

regenRoutes = (req, res) ->
  fs.readFile 'redirects.json', 'utf-8', (err, data) ->
    if (err)
      throw err
    routes = JSON.parse(data)
    done req, res, "/command/regenroutes"
  
commands = {
  "/command/regenroutes": regenRoutes
}

choose_path = (req, res) ->
  url = urls.parse(req.url).pathname
  for i, j of commands
    if url is i
      j req, res
      return
  if routes[url]?
    threeohone(req, res, routes[url])
    return
  fourohfour(req, res, url)

server = http.createServer (req, res) ->
  choose_path(req, res)

server.listen 8080

console.log "Shorturl server running at http://localhost:8080/"
