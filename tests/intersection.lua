local Regex = require("src/model/regex")
local Automaton = require("src/model/automaton")
require("src/r2nfa_converter/thompson")
require "src/automaton_functions/determinization"
require "src/automaton_functions/intersection"

local r1 = Regex.Regex:new("(a|ba)*")
local nfa = create_thompson_automaton(r1)
local dfa1 = Det(nfa)
dfa1:addTrap()
print(dfa1:tostring())

local r2 = Regex.Regex:new("(ba|bb)")
local nfa = create_thompson_automaton(r2)
local dfa2 = Det(nfa)
dfa2:addTrap()
print(dfa2:tostring())

local dfa_intersect = intersect_dfa(dfa1, dfa2)
print(dfa_intersect:tostring())