#include <memory>
#include <Rcpp.h>
#include "RedisContext.hpp"
#include "extract.hpp"

using namespace Rcpp;

//[[Rcpp::export]]
SEXP rredisInternalResponse(RObject Rc) {
	BEGIN_RCPP
	redisContext* c(extract_ptr<RredisContext>(Rc)->get_ptr());
	std::auto_ptr<redisReply> r;
	{
		redisReply *reply;
		redisGetReply(c, (void**) &reply);
		r.reset(reply);
	}
	if (r.get() == NULL) {
		throw std::runtime_error(std::string(c->errstr));
	}
	return extract_reply(r.get());
	END_RCPP
}
