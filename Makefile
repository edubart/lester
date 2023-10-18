ROCKSPEC=rockspecs/lester-0.*.rockspec
LUA=lua
LUACOV=luacov
LUALCOV=$(LUA) -lluacov

test:
	LESTER_TEST_SKIP_FAIL=true $(LUA) tests.lua

coverage:
	rm -f luacov.stats.out
	$(LUA) -lluacov tests.lua
	LESTER_QUIET=true $(LUALCOV) tests.lua
	LESTER_COLOR=false $(LUALCOV) tests.lua
	LESTER_SHOW_TRACEBACK=false $(LUALCOV) tests.lua
	LESTER_SHOW_ERROR=false $(LUALCOV) tests.lua
	LESTER_STOP_ON_FAIL=true $(LUALCOV) tests.lua || true
	LESTER_QUIET=true LESTER_STOP_ON_FAIL=true $(LUALCOV) tests.lua || true
	LESTER_FILTER="nested" LESTER_TEST_SKIP_FAIL=true $(LUALCOV) tests.lua
	LESTER_TEST_SKIP_FAIL=true $(LUALCOV) tests.lua
	LESTER_TEST_SKIP_FAIL=true LESTER_QUIET=true $(LUALCOV) tests.lua

	$(LUALCOV) tests.lua --quiet
	$(LUALCOV) tests.lua --no-color
	$(LUALCOV) tests.lua --no-show-traceback
	$(LUALCOV) tests.lua --no-show-error
	$(LUALCOV) tests.lua --stop-on-fail|| true
	$(LUALCOV) tests.lua --quiet --stop-on-fail || true
	$(LUALCOV) tests.lua --filter="nested" --test-skip-fail
	LESTER_TEST_SKIP_FAIL=true $(LUALCOV) tests.lua
	LESTER_TEST_SKIP_FAIL=true $(LUALCOV) tests.lua --quiet

	$(LUACOV)
	tail -n 6 luacov.report.out

docs:
	ldoc -d docs -f markdown -t "Lester Reference" lester.lua

install:
	luarocks make --local

upload:
	luarocks upload --api-key=$(LUAROCKS_APIKEY) $(ROCKSPEC)

clean:
	rm -f *.out

.PHONY: docs
