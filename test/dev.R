library(rredis)
redisConnect()
redisSet("a", "test")
redisGet("a")

library(rbenchmark)
benchmark(
	redisSet("a", 123)
)
