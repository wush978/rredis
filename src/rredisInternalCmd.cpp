#include <memory>
#include <Rcpp.h>
#include "RedisContext.hpp"

template<class T>
T* extract_ptr(SEXP s) {
	Rcpp::S4 s4(s);
	Rcpp::Environment env(s4);
	Rcpp::XPtr<T> xptr(env.get(".pointer"));
	return static_cast<T*>(R_ExternalPtrAddr(xptr));
}

using namespace Rcpp;

static void extract_array(redisReply *node, List& retval);
static SEXP extract_reply(redisReply *r);

//[[Rcpp::export]]
SEXP rredisInternalCmd(RObject Rc, List Rargv) {
	BEGIN_RCPP
	redisContext* c(extract_ptr<RredisContext>(Rc)->get_ptr());
	std::vector<const char*> argv(Rargv.size());
	std::vector<size_t> argvlen(Rargv.size());
	for(int i = 0;i < Rargv.size();i++) {
		argv[i] = (const char*) RAW(wrap(Rargv[i]));
		argvlen[i] = Rf_length(wrap(Rargv[i]));
	}
	std::auto_ptr<redisReply> r((redisReply*) redisCommandArgv(c, Rargv.size(), &argv[0], &argvlen[0]));
	if (r.get() == NULL) {
		throw std::runtime_error(std::string(c->errstr));
	}
	return extract_reply(r.get());
	END_RCPP
}

void extract_array(redisReply *node, List& retval) {
	for(int i = 0;i < node->elements;i++) {
		retval[i] = extract_reply(node->element[i]);
	}
}

SEXP extract_reply(redisReply *r) {
	switch(r->type) {
	case REDIS_REPLY_STRING: 
	case REDIS_REPLY_STATUS: {
		RawVector retval(r->len);
		memcpy(&retval[0], r->str, r->len);
		return retval;
	}
	case REDIS_REPLY_ERROR: {
		std::string retval(r->str, r->len);
		throw std::runtime_error(retval.c_str());
	}
	case REDIS_REPLY_INTEGER: {
		if (r->integer > INT_MAX) {
			NumericVector retval(1);
			memcpy(&retval[0], &(r->integer), sizeof(double));
			retval.attr("class") = wrap("integer64");
			return retval;
		}
		else {
			int retval = r->integer;
			return wrap(retval);
		}
	}
	case REDIS_REPLY_NIL: {
		return R_NilValue;
	}
	case REDIS_REPLY_ARRAY: {
		List retval;
		extract_array(r, retval);
		return retval;
	}
	default:
		throw std::logic_error("Unknown type");
	}
}