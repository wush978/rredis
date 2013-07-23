#include <Rcpp.h>
#include "RedisContext.hpp"

RredisContext::RredisContext(std::string host, int port, int timeout, std::string password) 
: c(redisConnect(host.c_str(), port)) {
	if (c != NULL && c->err) {
		std::stringstream ss;
		ss << "Error: " << c->errstr << std::endl;
    throw std::runtime_error(ss.str());
	}
}

RredisContext::~RredisContext() {
	redisFree(c);
	c = NULL;
}

redisContext* RredisContext::get_ptr() { return c; }

int RredisContext::get_err() {
	return c->err;
}

std::string RredisContext::get_errstr() {
	return std::string(c->errstr, 128);
}

int RredisContext::get_fd() {
	return c->fd;
}

int RredisContext::get_flags() {
	return c->flags;
}

using namespace Rcpp;

RCPP_EXPOSED_CLASS(RredisContext)

RCPP_MODULE(hiredis) {
	class_<RredisContext>("redisContext")
	.constructor<std::string, int, int, std::string>()
	.property("err", &RredisContext::get_err)
	.property("errstr", &RredisContext::get_errstr)
	.property("fd", &RredisContext::get_fd)
	.property("flags", &RredisContext::get_flags)
	;
}