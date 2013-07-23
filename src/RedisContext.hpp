#ifndef __RREDISCONTEXT_HPP__
#define __RREDISCONTEXT_HPP__

#include "hiredis/hiredis.h"
#include <string>

class RredisContext {
	redisContext* c;
public:
	RredisContext(std::string host, int port, int timeout, std::string password);
	~RredisContext();

	redisContext* get_ptr();
	int get_err();
	std::string get_errstr();
  int get_fd();
	int get_flags();

};

#endif //__RREDISCONTEXT_HPP__