test:
	LUA_PATH="./lua/?.lua;./lua/?/init.lua;;" busted spec
