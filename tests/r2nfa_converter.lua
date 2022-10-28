local Regex = require("src/model/regex")
local Automaton = require("src/model/automaton")
local eps = Automaton.eps
require("src/r2nfa_converter/thompson")
require("src/r2nfa_converter/antimirov")
require("src/r2nfa_converter/utils")

-- src/r2nfa_converter/utils
print("Test single operation automaton creation")
local tr1 = {Automaton.Transition:new(1, 2, "a")}
local tr2 = {Automaton.Transition:new(1, 2, "b"), Automaton.Transition:new(2, 3, "a")}
local a1 = Automaton.Automaton:new(2, {2}, tr1)
local a2 = Automaton.Automaton:new(3, {3}, tr2)

-- concatination (m1)(m2)
local merged = automatons_concat(a1, a2)

-- alternative
local alt = automatons_alt(a1, a2)

-- Kleene star
local iter = automatons_iter(a2)
local iter = automatons_iter(a2, false)

-- Kleene plus
local iter = automatons_iter(a2, true)


-- src/r2nfa_converter
print("Test Thompson automaton Th(R)")
local r = Regex.Regex:new("(((a|(c|d)*)|bc)*)")
local r1 = Regex.Regex:new("(a|b*)")
local r2 = Regex.Regex:new("(a|ba)*")
local a = create_thompson_automaton(r2)
-- print(a:tostring())


print("Test Antimirov automaton")
local r = Regex.Regex:new("(ab|b)*ba")
local a = create_antimirov_automaton(r)
print(a:tostring())

local r1 = Regex.Regex:new("a*")
local a = create_antimirov_automaton(r1)
print(a:tostring())


local r1 = Regex.Regex:new("a*|b*")
local a = create_antimirov_automaton(r1)
print(a:tostring())
