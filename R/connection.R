`redisConnect` <-
	function(host='localhost', port=6379, returnRef=FALSE, timeout=2678399L, password=NULL)
	{
		.redisEnv$current <- new.env()
		# R nonblocking connections are flaky, especially on Windows, see
		# for example:
		# http://www.mail-archive.com/r-devel@r-project.org/msg16420.html.
		# So, we use blocking connections now.
		con <- new(redisContext, host, port, timeout)
		# Stash state in the redis enivronment describing this connection:
		assign('con',con,envir=.redisEnv$current)
		assign('host',host,envir=.redisEnv$current)
		assign('port',port,envir=.redisEnv$current)
		assign('block',TRUE,envir=.redisEnv$current)
		assign('timeout',timeout,envir=.redisEnv$current)
		# Count is for nonblocking communication, it keeps track of the number of
		# getResponse calls that are pending.
		assign('count',0,envir=.redisEnv$current)
# 		if (!is.null(password)) tryCatch(redisAuth(password), 
# 																		 error=function(e) {
# 																		 	cat(paste('Error: ',e,'\n'))
# 																		 	close(con);
# 																		 	rm(list='con',envir=.redisEnv$current)
# 																		 })
# 		tryCatch(.redisPP(), 
# 						 error=function(e) {
# 						 	cat(paste('Error: ',e,'\n'))
# 						 	close(con);
# 						 	rm(list='con',envir=.redisEnv$current)
# 						 })
		if(returnRef) return(.redisEnv$current)
		invisible()
	}

# Connection will be close during gc
`redisClose` <- 
	function()
	{
# 		con <- .redis()
# 		close(con)
		remove(list='con',envir=.redisEnv$current)
	}
