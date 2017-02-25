colors = require 'colors'

initCommands = (program)->

  program
    .command('watson')
    .description('IBM Watson related utilities')
    .option('--speech-to-text <audio>', 'Convert <audio> file to text. Maximum size is 100MB.')
    .option('--output <JSON>', 'Write the output to a JSON file.')
    .action (options) ->

      Watson = require('./watson')

      if options.speechToText

        Watson.init( config.keys.watson['speech-to-text'] )
        Watson.speechToText({ 

          audio_file : options.speechToText 
          output     : options.output or null

        })
        .then((res)->

            console.log res

        ).catch(console.log)

module.exports = initCommands