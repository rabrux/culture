express = require 'express'
request = require 'request'
cheerio = require 'cheerio'
app     = express()

router  = express.Router()

# Routes
require( './hidalgo/cecultah' )( router, request, cheerio )

app.use '/', router

app.listen port = 1783

console.log "Magic happends on port #{ port }"