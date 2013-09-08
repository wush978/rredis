#include <memory>
#include <Rcpp.h>
#include "RedisContext.hpp"
#include "extract.hpp"

using namespace Rcpp;

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
