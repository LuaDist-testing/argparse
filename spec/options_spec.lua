local Parser = require "argparse"
getmetatable(Parser()).error = function(_, msg) error(msg) end

describe("tests related to options", function()
   describe("passing correct options", function()
      it("handles no options passed correctly", function()
         local parser = Parser()
         parser:option("-s", "--server")
         local args = parser:parse({})
         assert.same({}, args)
      end)

      it("handles one option correctly", function()
         local parser = Parser()
         parser:option("-s", "--server")
         local args = parser:parse({"--server", "foo"})
         assert.same({server = "foo"}, args)
      end)

      it("normalizes default target", function()
         local parser = Parser()
         parser:option("--from-server")
         local args = parser:parse({"--from-server", "foo"})
         assert.same({from_server = "foo"}, args)
      end)

      it("handles non-standard charset", function()
         local parser = Parser()
         parser:option "/s"
         parser:flag "/?"
         local args = parser:parse{"/s", "foo", "/?"}
         assert.same({s = "foo", ["?"] = true}, args)
      end)

      it("handles GNU-style long options", function()
         local parser = Parser()
         parser:option("-s", "--server")
         local args = parser:parse({"--server=foo"})
         assert.same({server = "foo"}, args)
      end)

      it("handles GNU-style long options even when it could take more arguments", function()
         local parser = Parser()
         parser:option("-s", "--server", {
            args = "*"
         })
         local args = parser:parse({"--server=foo"})
         assert.same({server = {"foo"}}, args)
      end)

      it("handles GNU-style long options for multi-argument options", function()
         local parser = Parser()
         parser:option("-s", "--server", {
            args = "1-2"
         })
         local args = parser:parse({"--server=foo", "bar"})
         assert.same({server = {"foo", "bar"}}, args)
      end)

      it("handles short option correclty", function()
         local parser = Parser()
         parser:option("-s", "--server")
         local args = parser:parse({"-s", "foo"})
         assert.same({server = "foo"}, args)
      end)

      it("handles flag correclty", function()
         local parser = Parser()
         parser:flag("-q", "--quiet")
         local args = parser:parse({"--quiet"})
         assert.same({quiet = true}, args)
         local args = parser:parse({})
         assert.same({}, args)
      end)

      it("handles combined flags correclty", function()
         local parser = Parser()
         parser:flag("-q", "--quiet")
         parser:flag("-f", "--fast")
         local args = parser:parse({"-qf"})
         assert.same({quiet = true, fast = true}, args)
      end)

      it("handles short options without space between option and argument", function()
         local parser = Parser()
         parser:option("-s", "--server")
         local args = parser:parse({"-sfoo"})
         assert.same({server = "foo"}, args)
      end)

      it("handles flags combined with short option correclty", function()
         local parser = Parser()
         parser:flag("-q", "--quiet")
         parser:option("-s", "--server")
         local args = parser:parse({"-qsfoo"})
         assert.same({quiet = true, server = "foo"}, args)
      end)

      it("interprets extra option arguments as positional arguments", function()
         local parser = Parser()
         parser:argument "input"
            :args "2+"
         parser:option "-s" "--server"
         local args = parser:parse{"foo", "-sFROM", "bar"}
         assert.same({input = {"foo", "bar"}, server = "FROM"}, args)
      end)

      it("does not interpret extra option arguments as other option's arguments", function()
         local parser = Parser()
         parser:argument "output"
         parser:option "--input"
            :args "+"
         parser:option "-s" "--server"
         local args = parser:parse{"--input", "foo", "-sFROM", "bar"}
         assert.same({input = {"foo"}, server = "FROM", output = "bar"}, args)
      end)

      it("does not pass arguments to options after double hyphen", function()
         local parser = Parser()
         parser:argument "input"
            :args "?"
         parser:option "--exclude"
            :args "*"
         local args = parser:parse{"--exclude", "--", "foo"}
         assert.same({input = "foo", exclude = {}}, args)
      end)

      describe("Special chars set", function()
         it("handles windows-style options", function()
            local parser = Parser()
               :add_help(false)
            parser:option "\\I"
               :count "*"
               :target "include"
            local args = parser:parse{"\\I", "src", "\\I", "misc"}
            assert.same({include = {"src", "misc"}}, args)
         end)

         it("corrects charset in commands", function()
            local parser = Parser "name"
               :add_help(false)
            parser:flag "-v" "--verbose"
               :count "*"
            parser:command "deep"
               :add_help(false)
               :option "/s"
            local args = parser:parse{"-v", "deep", "/s", "foo", "-vv"}
            assert.same({verbose = 3, deep = true, s = "foo"}, args)
         end)
      end)

      describe("Options with optional argument", function()
         it("handles emptiness correctly", function()
            local parser = Parser()
            parser:option("-p", "--password", {
               args = "?"
            })
            local args = parser:parse({})
            assert.same({}, args)
         end)

         it("handles option without argument correctly", function()
            local parser = Parser()
            parser:option("-p", "--password", {
               args = "?"
            })
            local args = parser:parse({"-p"})
            assert.same({password = {}}, args)
         end)

         it("handles option with argument correctly", function()
            local parser = Parser()
            parser:option("-p", "--password", {
               args = "?"
            })
            local args = parser:parse({"-p", "password"})
            assert.same({password = {"password"}}, args)
         end)
      end)

      it("handles multi-argument options correctly", function()
         local parser = Parser()
         parser:option("--pair", {
            args = 2
         })
         local args = parser:parse({"--pair", "Alice", "Bob"})
         assert.same({pair = {"Alice", "Bob"}}, args)
      end)

      describe("Multi-count options", function()
         it("handles multi-count option correctly", function()
            local parser = Parser()
            parser:option("-e", "--exclude", {
               count = "*"
            })
            local args = parser:parse({"-efoo", "--exclude=bar", "-e", "baz"})
            assert.same({exclude = {"foo", "bar", "baz"}}, args)
         end)

         it("handles not used multi-count option correctly", function()
            local parser = Parser()
            parser:option("-e", "--exclude", {
               count = "*"
            })
            local args = parser:parse({})
            assert.same({exclude = {}}, args)
         end)

         it("handles multi-count multi-argument option correctly", function()
            local parser = Parser()
            parser:option("-e", "--exclude", {
               count = "*",
               args = 2
            })
            local args = parser:parse({"-e", "Alice", "Bob", "-e", "Emma", "Jacob"})
            assert.same({exclude = {{"Alice", "Bob"}, {"Emma", "Jacob"}}}, args)
         end)

         it("handles multi-count flag correctly", function()
            local parser = Parser()
            parser:flag("-q", "--quiet", {
               count = "*"
            })
            local args = parser:parse({"-qq", "--quiet"})
            assert.same({quiet = 3}, args)
         end)

         it("overwrites old invocations", function()
            local parser = Parser()
            parser:option("-u", "--user", {
               count = "0-2"
            })
            local args = parser:parse({"-uAlice", "--user=Bob", "--user", "John"})
            assert.same({user = {"Bob", "John"}}, args)
         end)

         it("handles not used multi-count flag correctly", function()
            local parser = Parser()
            parser:flag("-q", "--quiet", {
               count = "*"
            })
            local args = parser:parse({})
            assert.same({quiet = 0}, args)
         end)
      end)
   end)

   describe("passing incorrect options", function()
      it("handles lack of required argument correctly", function()
         local parser = Parser()
         parser:option("-s", "--server")
         assert.has_error(function() parser:parse{"--server"} end, "too few arguments")
      end)

      it("handles unknown options correctly", function()
         local parser = Parser()
            :add_help(false)
         parser:option "--option"
         assert.has_error(function() parser:parse{"--server"} end, "unknown option '--server'")
         assert.has_error(function() parser:parse{"--server=localhost"} end, "unknown option '--server'")
         assert.has_error(function() parser:parse{"-s"} end, "unknown option '-s'")
         assert.has_error(function() parser:parse{"-slocalhost"} end, "unknown option '-s'")
      end)

      it("handles too many arguments correctly", function()
         local parser = Parser()
         parser:option("-s", "--server")
         assert.has_error(function() parser:parse{"-sfoo", "bar"} end, "too many arguments")
      end)

      it("doesn't accept GNU-like long options when it doesn't need arguments", function()
         local parser = Parser()
         parser:flag("-q", "--quiet")
         assert.has_error(function() parser:parse{"--quiet=very_quiet"} end, "option '--quiet' does not take arguments")
      end)

      it("handles too many invocations correctly", function()
         local parser = Parser()
         parser:flag("-q", "--quiet", {
            count = 1,
            overwrite = false
         })
         assert.has_error(function() parser:parse{"-qq"} end, "option '-q' must be used at most 1 time")
      end)

      it("handles too few invocations correctly", function()
         local parser = Parser()
         parser:option("-f", "--foo", {
            count = "3-4"
         })
         assert.has_error(function() parser:parse{"-fFOO", "-fBAR"} end, "option '-f' must be used at least 3 times")
      end)
   end)
end)
