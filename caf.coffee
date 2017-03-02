colors = require "colors"
glob = require "glob"
fsp = require 'fs-promise'
path = require 'path'

CaffeineMc = require 'caffeine-mc'

# Preload pre-compiled art-foundation for dramatically faster load-times...

{version} = require './package.json'
commander = require "commander"
.version version
.usage('[options] <input files and directories>')
.option '-o, --output <directory>', "where to write output files"
.option '-c, --compile', 'compile files'
.option '-p, --prettier', 'apply "prettier" to any js output'
.option '-v, --verbose', 'show more output'
.on "--help", ->
  console.log """
    An output directory is required if more than one input file is specified.

    Default action, if a file is provided, is to execute it.
    """
.parse process.argv

{output, compile, prettier, verbose} = commander

displayError = (e) ->
  {log, escapeRegExp} = Neptune.Art.Foundation
  if verbose
    log.error e
  else if e.message.match /parse|expect/i
    log e.message.replace /<HERE>/, "<HERE>".red if e
  else
    log.error(
      e.stack
      .split  "\n"
      .slice  0, 30
      .join   "\n"
      .replace new RegExp(escapeRegExp(process.cwd() + "/"), "g"), './'
      .replace new RegExp(escapeRegExp(path.dirname(process.cwd()) + "/"), "g"), '../'
    )


if compile
  files = commander.args
  {log, Promise, formattedInspect, each, escapeRegExp} = Neptune.Art.Foundation

  if !output and files.length == 1
    [filename] = files
    unless fsp.statSync(filename).isDirectory()
      output = path.dirname filename

  if files.length > 0 && output
    verbose && log compile:
      inputs: if files.length == 1 then files[0] else files
      output: output
    log "caffeine-mc loaded" if verbose
    log "using prettier" if verbose && prettier
    serializer = new Promise.Serializer

    filesRead = 0
    filesWritten = 0
    each files, (file) ->
      serializer.then ->
        CaffeineMc.compileFile file, outputDirectory: output, prettier: prettier
        .then ({readCount, writeCount}) ->
          log "compiled: #{file.green}" if verbose
          filesRead += readCount
          filesWritten += writeCount

    serializer.then ->
      log success: {filesRead, filesWritten}
    serializer.catch displayError
  else
    commander.outputHelp()
else if commander.args.length == 1
  [fileToRun] = commander.args
  require './register'
  file = path.resolve if fileToRun.match /^(\/|\.)/
    fileToRun
  else
    "./#{fileToRun}"

  try
    require file
  catch e
    displayError e
else
  commander.outputHelp()
