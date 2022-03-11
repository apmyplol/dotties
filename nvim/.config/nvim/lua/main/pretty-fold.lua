local status_ok, pfold = pcall(require, "pretty-fold")
if not status_ok then
  return
end

pfold.setup{
  config = {
     fill_char = '•',
     sections = {
        left = {
           'content',
        },
        right = {
           ' ', 'number_of_folded_lines', ': ', 'percentage', ' ',
           function(config) return config.fill_char:rep(3) end
        }
     },

     remove_fold_markers = true,

     -- Keep the indentation of the content of the fold string.
     keep_indentation = true,

     -- Possible values:
     -- "delete" : Delete all comment signs from the fold string.
     -- "spaces" : Replace all comment signs with equal number of spaces.
     -- false    : Do nothing with comment signs.
     process_comment_signs = 'spaces',

     -- Comment signs additional to the value of `&commentstring` option.
     comment_signs = {
        { '--[[', '--]]' },
    },

     -- List of patterns that will be removed from content foldtext section.
     stop_words = {
        '@brief%s*', -- (for C++) Remove '@brief' and all spaces after.
     },

     add_close_pattern = true, -- true, 'last_line' or false
     matchup_patterns = {
        -- beginning of the line -> any number of spaces -> 'do' -> end of the line
        { '^%s*do$', 'end' }, -- `do ... end` blocks
        { '^%s*if', 'end' },  -- if
        { '^%s*for', 'end' }, -- for
        { 'function%s*%(', 'end' }, -- 'function( or 'function (''
        { '{', '}' },
        { '%(', ')' }, -- % to escape lua pattern char
        { '%[', ']' }, -- % to escape lua pattern char
     },
  },
 -- custom_function_arg = 'Hello from inside custom function!',
 --   sections = {
 --      left = {
 --         function(config)
 --            return config.custom_function_arg
 --         end
 --      },
 --   }
}


-- Fold Preview setup
local status_ok, preview = pcall(require, "pretty-fold.preview")
if not status_ok then
  return
end

preview.setup{
  key = 'l', -- 'h', 'l' or nil (if you would like to set your own keybinding)

   -- 'none', "single", "double", "rounded", "solid", 'shadow' or table
   -- For explanation see: :help nvim_open_win()
   border = {' ', '', ' ', ' ', ' ', ' ', ' ', ' '},
}
