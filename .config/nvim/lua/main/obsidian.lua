local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local M = {}

local find_command = {
    "rg",
    "--files",
    "--ignore-file",
    ".rgignore",
    -- "&&",
    -- "rg",
    -- "-e",
    -- "'aliases: (.+)'",
    -- "--ignore-file",
    -- ".rgignore",
}

-- function to rename heading or block reference
-- only runs, if a heading or block was selected in the second prompt
local rename_heading_block = function(sel)
    local filename = sel.filename
    local attach = sel.attach

    local res = { attach, filename }

    opts = {}
    pickers
        .new(opts, {
            prompt_title = "Block/Heading Naming for File: " .. filename .. attach ,
            finder = finders.new_table {
                results = res,
                entry_maker = function(entry)
                    return sel
                end,
            },
            sorter = conf.file_sorter(opts),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()

                    local prompt_text = action_state.get_current_picker(prompt_bufnr).sorter._discard_state.prompt
                    actions.close(prompt_bufnr)

                    vim.api.nvim_put({ "[[" .. filename .. attach .. "|" .. prompt_text .. "]] " }, "", false, true)
                    vim.api.nvim_input "a"
                end)
                return true
            end,
        })
        :find()
end

-- prompt that renames a file or selects a heading / block in a file and opens another prompt to rename the heading / block reference
local obsidian_rename = function(inp_fname)
    local fname, ext = inp_fname:match "([^/.]+)%.(.*)$"
    fname = ext == "md" and fname or fname .. "." .. ext
    -- only search for aliases and ^^ things in file if markdown file
    -- but either way add fname as a result
    local res = { fname }

    if ext == "md" then
        local alias_match = vim.fn.system("rg -e 'aliases:' " .. inp_fname)
        local block_ref = vim.fn.system("rg -e '^\\^' " .. inp_fname)
        local heading_ref = vim.fn.system("rg -e '^#' " .. inp_fname)

        -- add aliases to result list
        for str in alias_match:gsub("aliases:%s?", ""):gsub("\n", ""):gsub(",%s", "~"):gmatch "[^~]+" do
            if str ~= "" then
                res[#res + 1] = str
            end
        end

        for str in block_ref:gmatch "[^\n]+" do
            res[#res + 1] = str
        end

        for str in heading_ref:gmatch "[^\n]+" do
            res[#res + 1] = str
        end
    end

    local opts = {}
    pickers
        .new(opts, {
            prompt_title = "Ref Naming, Block/Heading selection for File: " .. fname,
            finder = finders.new_table {
                results = res,
                entry_maker = function(entry)
                    -- is this a file reference or header/block reference
                    local fileref = true
                    -- what to attach to the filename in the reference
                    local lattach = ""
                    local display = ""
                    local mathref = false
                    -- if entry is the filename, then attach nothing, and set filereference to true
                    if entry == fname then
                        lattach = entry:find "_" and "|" .. entry:gsub("_", " ") or ""
                        display = entry:find "_" and "|" .. entry:gsub("_", " ") or entry
                    elseif entry:find "^^" then
                        fileref = false
                        lattach = "#" .. entry
                        display = lattach
                    elseif entry:find "^#" then
                        fileref = false
                        lattach = "" .. entry
                        display = lattach
                    else
                        lattach = "|" .. entry
                        display = lattach
                    end
                    return {
                        -- attach what is being displayed
                        display = display,
                        attach = lattach,
                        ordinal = entry,
                        filename = fname,
                        fileref = fileref,
                        mathref = mathref,
                    }
                end,
            },
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, map)
                --[[ local prompt_text = action_state.get_current_picker(prompt_bufnr).sorter._discard_state.prompt ]]
                actions.select_default:replace(function()
                    local prompt_text = action_state.get_current_picker(prompt_bufnr).sorter._discard_state.prompt
                    local selection = action_state.get_selected_entry()
                    -- if the selection is nil then use the prompt text, else the selection attach
                    local attach = selection == nil and "|" .. prompt_text or selection.attach
                    if selection.fileref == true then
                    actions.close(prompt_bufnr)
                    vim.api.nvim_put({ "[[" .. fname .. attach .. "]] " }, "", false, true)
                    -- vim.api.nvim_command "startinsert"
                    -- vim.cmd("startinsert")
                    vim.api.nvim_input "a"
                    else
                        rename_heading_block(selection)
                    end
                end)

                map("i", "<C-CR>", function()
                    local prompt_text = action_state.get_current_picker(prompt_bufnr).sorter._discard_state.prompt
                    actions.close(prompt_bufnr)

                    vim.api.nvim_put({ "[[" .. fname .. "|" .. prompt_text .. "]] " }, "", false, true)
                    vim.api.nvim_input "a"
                end)
                return true
            end,
        })
        :find()
end

function M.obsidian(opts)
    opts = opts or {}
    pickers
        .new(opts, {
            prompt_title = "Reference File",
            finder = finders.new_oneshot_job(find_command, opts),
            sorter = conf.file_sorter(opts),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local filename = action_state.get_selected_entry()[1]
                    obsidian_rename(filename)
                end)
                map("i", "<C-CR>", function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()[1]:match "([^/.]+)%..*$"
                    selection = selection:find "_" == nil and selection or selection .. "|" .. selection:gsub("_", " ")

                    vim.api.nvim_put({ "[[" .. selection .. "]] " }, "", false, true)
                    vim.api.nvim_input "a"
                end)
                return true
            end,
        })
        :find()
end

M.main = function()
    --[[ M.obsidian(require("telescope.themes").get_dropdown {}) ]]
    M.obsidian()
end
return M
