moment = require 'moment-timezone'

scrapChilds = ( $, element, lorem ) ->
  element.children().each () ->
    switch @.name
      when 'img'
        lorem.push
          type: 'IMAGE'
          url: $( @ ).attr 'src'
        break
      when 'p'
        for p in $( @ ).html().split('<br>')
          if p.length > 0
            lorem.push
              type: 'TEXT'
              content: p
        break
      when 'iframe'
        src = $( @ ).attr 'src'
        if src.match /.*(youtube\.com|vimeo\.com).*/
          lorem.push
            type: 'VIDEO'
            url: src
        # else 
        #   console.log 'iframe ::: ', $( @ ).html()
        break
      when 'div'
        scrapChilds( $, $( @ ), lorem )
        break
      # else
      #   console.log 'unknown :: ' + @.name, $( @ ).html()

module.exports = ( router, request, cheerio ) ->

  router.route '/cecultah'
    .get ( req, res ) ->
      url = 'http://cecultah.hidalgo.gob.mx/?page_id=4114'

      request url, ( error, response, html ) ->
        if !error
          $ = cheerio.load html
          $month = $('.ecwd-page-full.ecwd_calendar')
          events = []
          $month.find('.day-with-date.has-events').each ( i, el ) ->
            $el = $ @
            event =
              date: $el.data 'date'
            $el
              .find 'ul.events li'
              .each ( index, ev ) ->
                $ev = $ @
                event.name      = $ev.find( '.event-details .event-details-title [itemprop=name]' ).text()
                event.url       = $ev.find( '.event-details .event-details-title [itemprop=name] a' ).attr 'href'
                event.startTime = $ev.find( '.event-details .ecwd-time [itemprop=startDate]' ).attr 'content'
                event.startTime = moment( event.startTime ).tz('America/Mexico_City').format( 'x' )
                startEnd = $ev.find( '.event-details .ecwd-time [itemprop=startDate]' ).text().split( '-' )
                if startEnd[0]
                  event.startHour = startEnd[0].trim()
                if startEnd[1]
                  event.endHour = startEnd[1].trim()
                event.location =
                  name: $ev.find( '.event-details .event-venue[itemprop=location] .ecwd-venue span[itemprop=name]' ).text()
                  url: $ev.find( '.event-details .event-venue[itemprop=location] .ecwd-venue span[itemprop=name] a' ).attr 'href'
                  address: $ev.find( '.event-details .ecwd-location[itemprop=address]' ).text()
                $description = $ev.find( '.event-details .ecwd-detalis[itemprop=description]' )
                lorem = []
                scrapChilds( $, $description, lorem )
                event.description = lorem
                events.push event
          res.send
            success: true
            events: events

        else throw error
