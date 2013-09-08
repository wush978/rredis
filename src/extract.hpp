#ifndef __EXTRACT_HPP__
#define __EXTRACT_HPP__

#include <Rcpp.h>
#include "RedisContext.hpp"

template<class T>
T* extract_ptr(SEXP s) {
	Rcpp::S4 s4(s);
	Rcpp::Environment env(s4);
	Rcpp::XPtr<T> xptr(env.get(".pointer"));
	return static_cast<T*>(R_ExternalPtrAddr(xptr));
}

void extract_array(redisReply *node, Rcpp::List& retval);
SEXP extract_reply(redisReply *r);

#endif //__EXTRACT_HPP__