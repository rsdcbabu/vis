# Description:
# Create google calendar events with Hubot.
#
# Commands:
# hubot remind me to <title> - Creates an event with title in google primary calendar.
#
# Notes:

calendarClientId = 
calendarClientSecret =
calendarRefreshToken = 
calendarRedirectUri = 
calendarId = "primary"

googleapis = require('googleapis')

module.exports = (robot) ->
  robot.respond /(.*?)remind( me to)?\s*(.+)?/, (msg) ->
    summary = msg.match[3] or "Some reminder"

    createCalendarEvent msg, summary, (err, event) ->
      if err
        msg.send "I'm sorry. Something went wrong and I wasn't able to create a hangout :("
      else
        response = "Sure Sir!\n"
        msg.send response

  createCalendarEvent = (msg, summary, callback) ->
    withGoogleClient msg, (client) ->
      req = client.calendar.events.quickAdd { calendarId: calendarId, text:summary }
      req.withAuthClient(client.authClient).execute(callback)

  googleClient = undefined
  withGoogleClient = (msg, callback) ->
    if googleClient?
      callback(googleClient)
    else
      return if missingEnvironmentForApi(msg)
      googleapis.discover('calendar', 'v3').execute (err, client) ->
        if err
          msg.send "I'm sorry. I wasn't able to communicate with Google right now :("
        else
          authClient = new googleapis.OAuth2Client(
            calendarClientId, calendarClientSecret, calendarRedirectUri
          )
          authClient.credentials = { refresh_token: calendarRefreshToken }

          googleClient = client.withAuthClient(authClient)
          callback(googleClient)

  missingEnvironmentForApi = (msg) ->
    missingAnything = false
    unless calendarClientId?
      msg.send "Calendar Client ID is missing: Ensure that HUBOT_GOOGLE_CALENDAR_CLIENT_ID is set."
      missingAnything = true
    unless calendarClientSecret?
      msg.send "Calendar Client Secret is missing: Ensure that HUBOT_GOOGLE_CALENDAR_CLIENT_SECRET is set."
      missingAnything = true
    unless calendarRefreshToken?
      msg.send "Calendar Refresh Token is missing: Ensure that HUBOT_GOOGLE_CALENDAR_REFRESH_TOKEN is set."
      missingAnything = true
    missingAnything
