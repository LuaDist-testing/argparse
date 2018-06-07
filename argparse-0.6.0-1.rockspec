-- This file was automatically generated for the LuaDist project.

package = "argparse"
version = "0.6.0-1"
-- LuaDist source
source = {
  tag = "0.6.0-1",
  url = "git://github.com/LuaDist-testing/argparse.git"
}
-- Original source
-- source = {
--    url = "git+https://github.com/mpeterv/argparse.git",
--    tag = "0.6.0"
-- }
description = {
   summary = "A feature-rich command-line argument parser",
   detailed = "Argparse supports positional arguments, options, flags, optional arguments, subcommands and more. Argparse automatically generates usage, help and error messages.",
   homepage = "https://github.com/mpeterv/argparse",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1, < 5.4"
}
build = {
   type = "builtin",
   modules = {
      argparse = "src/argparse.lua"
   }
}