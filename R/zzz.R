#'@export
#'@useDynLib rredis
.onLoad <- function(libname, pkgname) {
	loadRcppModules()
}