local evatheme    = require("colors.evatheme_lush")
local lushwright = require("shipwright.transform.lush")
run(evatheme,
  lushwright.to_lua,
  {patchwrite, "/home/afa/.config/nvim/lua/colors/evatheme.lua", "-- PATCH_OPEN", "-- PATCH_CLOSE"})
