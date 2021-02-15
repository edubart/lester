LUA=lua
LUACOV=luacov
LUALCOV=$(LUA) -lluacov

coverage-test:
	rm -f luacov.stats.out
	$(LUA) -lluacov tests.lua
	LUSTED_QUIET=true $(LUALCOV) tests.lua
	LUSTED_COLORED=false $(LUALCOV) tests.lua
	LUSTED_SHOW_TRACEBACK=false $(LUALCOV) tests.lua
	LUSTED_SHOW_ERROR=false $(LUALCOV) tests.lua
	LUSTED_STOP_ON_FAIL=true $(LUALCOV) tests.lua || true
	LUSTED_QUIET=true LUSTED_STOP_ON_FAIL=true $(LUALCOV) tests.lua || true
	LUSTED_TEST_SKIP_FAIL=true $(LUALCOV) tests.lua
	$(LUACOV)
	tail -n 6 luacov.report.out
