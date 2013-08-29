# This file contains various control functions.

# Basic response handler, only really useful in nonblocking cases
# all function argument is left in for backward compatibility,
# it is not used.
`redisGetResponse` <- function(all=TRUE)
{
  if(!exists('count',where=.redisEnv$current)) return(.getResponse())
  if(.redisEnv$current$count < 1) return(NULL)
  replicate(.redisEnv$current$count, .getResponse(), simplify=FALSE)
}

`redisSetBlocking` <- function(value=TRUE)
{
  value <- as.logical(value)
  if(is.na(value)) stop("logical value required")
  assign('block',value,envir=.redisEnv$current)
}

`redisAuth` <- 
function(pwd)
{
  .redisCmd(.raw('AUTH'), .raw(pwd))
}

`redisSave` <-
function()
{
  .redisCmd(.raw('SAVE'))
}

`redisBgSave` <-
function()
{
  .redisCmd(.raw('BGSAVE'))
}

`redisBgRewriteAOF` <-
function()
{
  .redisCmd(.raw('BGREWRITEAOF'))
}

`redisShutdown` <-
function()
{
  .redisCmd(.raw('SHUTDOWN'))
  remove(list='con',envir=.redisEnv$current)
}

`redisInfo` <-
function()
{
  x <- .redisCmd(.raw('INFO'))
  z <- strsplit(x,'\r\n')[[1]]
  rj <- c(grep("^$",z), grep("^#",z))
  if(length(rj)>0) z <- z[-rj]
  w <- unlist(lapply(z,strsplit,':'))
  n <- length(w)
  e <- seq(from=2,to=n,by=2)
  o <- seq(from=1,to=n,by=2)
  z <- as.list(w[e])
  names(z) <- w[o]
  z
}

`redisSlaveOf` <-
function(host,port)
{
# Use host="no" port="one" to disable slave replication
  .redisCmd(.raw('SLAVEOF'),.raw(as.character(host)), .raw(as.character(port)))
}

redisFlushDB <- function() {
  .redisCmd(.raw('FLUSHDB'))
}

redisFlushAll <- function() {
  .redisCmd(.raw('FLUSHALL'))
}

redisSelect <- function(index) {
  .redisCmd(.raw('SELECT'),.raw(as.character(index)))
}

redisDBSize <- function() {
  .redisCmd(.raw('DBSIZE'))
}

redisGetContext <- function() {
  .redisEnv$current
}

redisSetContext <- function(e=NULL)
{
  if(is.null(e)) .redisEnv$current <- .redisEnv
  else {
    if(!is.environment(e)) stop("Invalid context")
    .redisEnv$current <- e
  }
}
