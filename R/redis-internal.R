# This file contains functions and environments used internally 
# by the rredis package (not exported in the namespace).

.redisEnv <- new.env()
.redisEnv$current <- .redisEnv

.redis <- function() 
{
  if(!exists('con',envir=.redisEnv$current))
    stop('Not connected, try using redisConnect()')
  .redisEnv$current$con
}

# .redisError may be called by any function when a serious error occurs.
# It will print an indicated error message, attempt to reset the current
# Redis server connection, and signal the error.
.redisError <- function(msg, e=NULL)
{
  env <- .redisEnv$current
  con <- .redis()
  close(con)
# May stop with an error here on connect fail
  con <- socketConnection(env$host, env$port,open='a+b', blocking=TRUE, timeout=env$timeout)
  assign('con',con,envir=env)
  if(!is.null(e)) print(as.character(e))
  stop(msg)
}

.redisPP <- function() 
{
  # Ping-pong
  .redisCmd(.raw('PING'))
}

.cerealize <- function(value) 
{
  if(!is.raw(value)) serialize(value,ascii=FALSE,connection=NULL)
  else value
}

# Burn data in the RX buffer, used after interrupt conditions
.burn <- function(e)
{
  con <- .redis()
  while(socketSelect(list(con),timeout=1L))
    readBin(con, raw(), 1000000L)
  .redisError("Interrupted communincation with Redis",e)
}

#
# .raw is just a shorthand wrapper for charToRaw:
#
.raw <- function(word) 
{
  tryCatch(charToRaw(word),warning=function(w) stop(w), error=function(e) stop(e))
}

# Expose the basic Redis interface to the user
redisCmd <- function(CMD, ..., raw=FALSE)
{
  a <- c(alist(),list(.raw(CMD)),
         lapply(list(...), function(x) 
           if(is.character(x)) charToRaw(x)
           else(.cerealize(x))
       ))
  if(raw) return(do.call('.redisRawCmd',a))
  do.call('.redisCmd', a)
}

.redisRawCmd <- function(...)
{
  con <- .redis()
  f <- match.call()
  n <- length(f) - 1
  hdr <- paste('*', as.character(n), '\r\n',sep='')
# Check to see if a rename list exists and use it if it does...we also
  rep = c()
  if(exists("rename",envir=.redisEnv)) rep = get("rename",envir=.redisEnv)
  cat(hdr, file=con)
tryCatch({
  for(j in seq_len(n)) {
      if(j==1)
        v <- .renameCommand(eval(f[[j+1]],envir=sys.frame(-1)), rep)
      else
        v <- eval(f[[j+1]],envir=sys.frame(-1))
    if(!is.raw(v)) v <- .cerealize(v)
    l <- length(v)
    hdr <- paste('$', as.character(l), '\r\n', sep='')
    cat(hdr, file=con)
    writeBin(v, con)
    cat('\r\n', file=con)
  }
},
error=function(e) {.redisError("Invalid agrument");invisible()},
interrupt=function(e) .burn(e)
)
  .getResponse(raw=TRUE)
}

.renameCommand <- function(x, rep)
{
  if(is.null(rep)) return(x)
  v = rawToChar(x)
  if(v %in% names(rep)) return(charToRaw(rep[[v]]))
  x
}
