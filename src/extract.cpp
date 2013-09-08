#include <Rcpp.h>
#include "extract.hpp"

using namespace Rcpp;

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
