# generated by Neptune Namespaces v1.x.x
# file: CaffeineMc/index.coffee

module.exports = require './namespace'
.includeInNamespace require './CaffeineMc'
.addModules
  CaffeineMcParser: require './CaffeineMcParser'
  CafRepl:          require './CafRepl'         
  FileCompiler:     require './FileCompiler'    
  Metacompiler:     require './Metacompiler'    
  ModuleResolver:   require './ModuleResolver'  
  SourceRoots:      require './SourceRoots'     
require './Compilers'