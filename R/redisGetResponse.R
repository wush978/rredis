.getResponse <- function(raw=FALSE)
{
	env <- .redisEnv$current
	tryCatch({
		con <- .redis()
		#  socketSelect(list(con), timeout=10L)
# 		l <- readLines(con=con, n=1)
# 		if(length(l)==0) .burn("Empty")
		result.raw <- rredisInternalResponse(con)
		if (class(result.raw) == "raw") {
			result <- try(unserialize(result.raw), silent=TRUE)
			if (class(result) == "try-error") {
				result <- rawToChar(result.raw)
			}
		} else {
			result <- result.raw
		}
		tryCatch(
			env$count <- max(env$count - 1,0),
			error = function(e) assign('count', 0, envir=env)
		)
# 		s <- substr(l, 1, 1)
# 		if (nchar(l) < 2) {
# 			if(s == '+') {
# 				# '+' is a valid retrun message on at least one cmd (RANDOMKEY)
# 				return('')
# 			}
# 			.burn("Invalid")
# 		}
# 		switch(s,
# 					 '-' = stop(substr(l,2,nchar(l))),
# 					 '+' = substr(l,2,nchar(l)),
# 					 ':' = as.numeric(substr(l,2,nchar(l))),
# 					 '$' = {
# 					 	n <- as.numeric(substr(l,2,nchar(l)))
# 					 	if (n < 0) {
# 					 		return(NULL)
# 					 	}
# 					 	#             socketSelect(list(con),timeout=10L)
# 					 	dat <- tryCatch(readBin(con, 'raw', n=n),
# 					 									error=function(e) .redisError(e$message))
# 					 	m <- length(dat)
# 					 	if(m==n) {
# 					 		#               socketSelect(list(con),timeout=10L)
# 					 		l <- readLines(con,n=1)  # Trailing \r\n
# 					 		if(raw)
# 					 			return(dat)
# 					 		else
# 					 			return(tryCatch(unserialize(dat),
# 					 											error=function(e) rawToChar(dat)))
# 					 	}
# 					 	# The message was not fully recieved in one pass.
# 					 	# We allocate a list to hold incremental messages and then concatenate it.
# 					 	# This perfromance enhancement was adapted from the Rbig server package, 
# 					 	# written by Steve Weston and Pat Shields.
# 					 	rlen <- 50
# 					 	j <- 1
# 					 	r <- vector('list',rlen)
# 					 	r[j] <- list(dat)
# 					 	while(m<n) {
# 					 		# Short read; we need to retrieve the rest of this message.
# 					 		#               socketSelect(list(con),timeout=10L)
# 					 		dat <- tryCatch(readBin(con, 'raw', n=(n-m)),
# 					 										error=function (e) .redisError(e$message))
# 					 		j <- j + 1
# 					 		if(j>rlen) {
# 					 			rlen <- 2*rlen
# 					 			length(r) <- rlen
# 					 		}
# 					 		r[j] <- list(dat)
# 					 		m <- m + length(dat)
# 					 	}
# 					 	#             socketSelect(list(con),timeout=10L)
# 					 	l <- readLines(con,n=1)  # Trailing \r\n
# 					 	length(r) <- j
# 					 	if(raw)
# 					 		do.call(c,r)
# 					 	else
# 					 		tryCatch(unserialize(do.call(c,r)),
# 					 						 error=function(e) rawToChar(do.call(c,r)))
# 					 },
# 					 '*' = {
# 					 	numVars <- as.integer(substr(l,2,nchar(l)))
# 					 	if(numVars > 0L) {
# 					 		replicate(numVars, .getResponse(raw=raw), simplify=FALSE)
# 					 	} else NULL
# 					 },
# 					 stop('Unknown message type'))
		return(result)
	}, interrupt=function(e) { }#.burn(e)
	)
}
