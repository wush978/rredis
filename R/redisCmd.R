# .redisCmd corresponds to the Redis "multi bulk" protocol. It 
# expects an argument list of command elements. Arguments that 
# are not of type raw are serialized.
# Examples:
# .redisCmd(.raw('INFO'))
# .redisCmd(.raw('SET'),.raw('X'), runif(5))
#
# We use match.call here instead of, for example, as.list() to try to 
# avoid making unnecessary copies of (potentially large) function arguments.
#
# We can further improve this by writing a shadow serialization routine that
# quickly computes the length of a serialized object without serializing it.
# Then, we could serialize directly to the connection, avoiding the temporary
# copy (which is limited to 2GB due to R indexing).
.redisCmd <- function(...)
{
	env <- .redisEnv$current
	con <- .redis()
	# Check to see if a rename list exists and use it if it does...we also
	# define a little helper function to handle replacing the command.
	# The rename list must have the form:
	# list(OLDCOMMAND="NEWCOMMAND", SOME_OTHER_CMD="SOME_OTHER_NEW_CMD",...)
	rep = c()
	if(exists("rename",envir=.redisEnv)) rep = get("rename",envir=.redisEnv)
	f <- match.call()
	n <- length(f) - 1
	cmdarg <- vector("list", n)
		for(j in seq_len(n)) {
			if(j==1)
				v <- .renameCommand(eval(f[[j+1]],envir=sys.frame(-1)), rep)
			else
				v <- eval(f[[j+1]],envir=sys.frame(-1))
			if(!is.raw(v)) v <- .cerealize(v)
			cmdarg[[j]] <- v
		}
	block <- TRUE
	if(exists('block',envir=env)) block <- get('block',envir=env)
	if(block) {
		result.raw <- rredisInternalCmd(con, cmdarg)
	# 	browser()
		if (class(result.raw) == "raw") {
			result <- try(unserialize(result.raw), silent=TRUE)
			if (class(result) == "try-error") {
				result <- rawToChar(result.raw)
				return(result)
			} else {
				return(result)
			}
		} else {
			return(result.raw)
		}
	} else { # non-blocking
# 		browser()
		rredisInternalAppendCmd(con, cmdarg)
		tryCatch(
			env$count <- env$count + 1,
			error = function(e) assign('count', 1, envir=env)
		)
		invisible()
	}
}
