ROCKSPEC=rockspecs/lusted-0.*.rockspec
LUA=lua
LUACOV=luacov
LUALCOV=$(LUA) -lluacov

test:
	LUSTED_TEST_SKIP_FAIL=true $(LUA) tests.lua

coverage:
	rm -f luacov.stats.out
	$(LUA) -lluacov tests.lua
	LUSTED_QUIET=true $(LUALCOV) tests.lua
	LUSTED_COLORED=false $(LUALCOV) tests.lua
	LUSTED_SHOW_TRACEBACK=false $(LUALCOV) tests.lua
	LUSTED_SHOW_ERROR=false $(LUALCOV) tests.lua
	LUSTED_STOP_ON_FAIL=true $(LUALCOV) tests.lua || true
	LUSTED_QUIET=true LUSTED_STOP_ON_FAIL=true $(LUALCOV) tests.lua || true
	LUSTED_FILTER="nested" LUSTED_TEST_SKIP_FAIL=true $(LUALCOV) tests.lua
	LUSTED_TEST_SKIP_FAIL=true $(LUALCOV) tests.lua
	LUSTED_TEST_SKIP_FAIL=true LUSTED_QUIET=true $(LUALCOV) tests.lua
	$(LUACOV)
	tail -n 6 luacov.report.out

docs:
	ldoc -d docs -f markdown -t "Lusted Reference" lusted.lua

install:
	luarocks make --local

upload:
	luarocks upload --api-key=$(LUAROCKS_APIKEY) $(ROCKSPEC)

clean:
	rm -f *.out

.PHONY: docs