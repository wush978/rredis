#include <Rcpp.h>
#include "RedisContext.hpp"
#include "extract.hpp"

using namespace Rcpp;

//[[Rcpp::export]]
SEXP rredisInternalAppendCmd(RObject Rc, List Rargv) {
	BEGIN_RCPP
	redisContext* c(extract_ptr<RredisContext>(Rc)->get_ptr());
	std::vector<const char*> argv(Rargv.size());
	std::vector<size_t> argvlen(Rargv.size());
	for(int i = 0;i < Rargv.size();i++) {
		argv[i] = (const char*) RAW(wrap(Rargv[i]));
		argvlen[i] = Rf_length(wrap(Rargv[i]));
	}
	redisAppendCommandArgv(c, Rargv.size(), &argv[0], &argvlen[0]);
	END_RCPP
}

