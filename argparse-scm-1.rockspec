package = "argparse"
version = "scm-1"
source = {
   url = "git+https://github.com/mpeterv/argparse.git"
}
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
