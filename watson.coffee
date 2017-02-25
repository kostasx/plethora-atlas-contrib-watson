colors = require 'colors'
got    = require 'got'
fs     = require 'fs'

API_URL = "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?continuous=true"

# TERMINAL COLORS
Reset     = "\x1b[0m"
FgRed     = "\x1b[31m"
FgGreen   = "\x1b[32m"
FgYellow  = "\x1b[33m"
FgCyan    = "\x1b[36m"

Watson = 

  creds: 

    username: ""
    password: ""

  init: (options)->

    Watson.creds.username = options.username
    Watson.creds.password = options.password

  speechToText: (options)->

    auth = "Basic " + new Buffer( Watson.creds.username + ":" + Watson.creds.password ).toString("base64")
    data = fs.readFileSync options.audio_file

    uploaded        = 0
    fileStats       = fs.statSync(options.audio_file)
    fileSizeInBytes = fileStats.size 
    sizeInMB        = (fileSizeInBytes / (1024*1024)).toFixed(2);

    if sizeInMB > 100
      console.log "Error: file size exceeds maximum 100MB limit.".red
      return Promise.resolve({ msg: "Error: file size exceeds maximum 100MB limit.", error: true })

    ProgressBar = require 'progress'
    bar = new ProgressBar('Uploading [:bar] :percent :etas',
      complete   : "#{FgRed}▇#{Reset}"
      incomplete : ' '
      width      : 20
      total      : fileSizeInBytes
    )

    stream = fs.createReadStream(options.audio_file)
    stream.on('data', (chunk)-> 
      uploaded += chunk.length
      uploadedPercentage = (( uploaded / fileSizeInBytes ) * 100).toFixed()
      bar.tick chunk.length
      if uploadedPercentage > 25
        bar.chars.complete = "#{FgYellow}▇#{Reset}"
      if uploadedPercentage > 50
        bar.chars.complete = "#{FgCyan}▇#{Reset}"
      if uploadedPercentage > 75
        bar.chars.complete = "#{FgGreen}▇#{Reset}"
    )

    got.post(API_URL, {

      json: true
      body: stream       # WITH PROGRESS:
      # body: data       # WITHOUT PROGRESS:
      encoding: null
      headers:
        "Authorization"     : auth
        "Content-Type"      : "audio/wav"
        "Transfer-Encoding" : "chunked"
      
    }).then((res)->

      results = res.body

      output = {
        msg        : ""
        statusCode : res.statusCode
        data       : JSON.stringify(results)
      }

      if options.output
        output.msg = "Results written to file."
        fs.writeFileSync(options.output, JSON.stringify(results), "utf8")

      return output


    ).catch((error)->

      console.log "Error", error

    )

module.exports = Watson