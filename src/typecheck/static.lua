local class = require("src/model/middleclass")
local Metadata = require("src/utils/converter_functions")
local EM = require("src/model/expression")

Typechecker = class("Typechecker")

identifiersList = {}


function Typechecker:typecheck(filename)
    local errors = {}

    for line in io.lines(filename) do
        local error = nil
        if (line:find("=") ~= nil) then
             error = Typechecker:checkDeclaration(line)
        elseif (line:lower():find("test") ~= nil) then
             error = Typechecker:checkTest(line)
        else
             error = Typechecker:checkPredicate(line)
        end
        if (error ~= nil) then
            print("Error at " .. line .. " : " .. error)
            return
        end
    end
    for k, v in pairs(errors) do
        print(v)
    end
    return #errors
end

function Typechecker:checkDeclaration(declaration)
    local lines = split(declaration, "=")
    local left = trim(lines[1])
    local right = trim(lines[2])
    local error, type = Typechecker:checkRightSide(right)
    identifiersList[left] = type
    return error
end

function Typechecker:checkRightSide(right)
    local lines = split(right, " ")
    if (#lines == 1) then
        return nil, Typechecker:whatType(lines[1])
    elseif (#lines == 2) then
        local funcs = split(lines[1], ".")
        if (Metadata.functions[funcs[#funcs]].argNum ~= 1) then
            print(funcs[#funcs], Metadata.functions[funcs[#funcs]].argNum)
            return "Too many arguments", nil
        end
        funcs[#funcs + 1] = lines[2]
        local currentType = Typechecker:whatType(funcs[#funcs])
        for i = #funcs - 1, 1, -1 do
            if (Metadata.functions[funcs[i]].first == currentType or 
                Metadata.functions[funcs[i]].first == Metadata.dataTypes.NFA and 
                currentType == Metadata.dataTypes.DFA) then
                currentType = Metadata.functions[funcs[i]].result
            else 
                return "Type mismatch", nil
                
            end
        end
        return nil, Metadata.functions[funcs[1]].result
    else 
        local funcs = split(lines[1], ".")
        if (Metadata.functions[funcs[#funcs]].argNum ~= 2) then
            return "Too few arguments", nil
        end
        funcs[#funcs + 1] = lines[2]
        funcs[#funcs + 1] = lines[3]
        local currentType = nil
        if (Typechecker:match(funcs[#funcs - 2], lines[2], lines[3])) then
            currentType = Metadata.functions[funcs[#funcs - 2]].result
        else 
            return "Type mismatch", nil
        end
        funcs[#funcs - 2] = EM.computable:new(funcs[#funcs - 2], EM.computableType.func, funcs[#funcs - 1], funcs[#funcs])
        for i = #funcs - 3, 1, -1 do
            if (Metadata.functions[funcs[i]].first == currentType or
                Metadata.functions[funcs[i]].first == Metadata.dataTypes.NFA and
                currentType == Metadata.dataTypes.DFA) then
                    currentType = Metadata.functions[funcs[i]].result
                else
                    return "Type mismatch", nil
                end
        end
        return nil, Metadata.functions[funcs[1]].result
    end
end

function Typechecker:checkTest(test)
    local args = split(line:sub(6, #line - 1), ",")
    local arg1 = trim(args[1])
    local arg2 = trim(args[2])
    local arg3 = trim(args[3])
    if ((Typechecker:whatType(arg1) == Metadata.dataTypes.DFA or Typechecker:whatType(arg1) == Metadata.dataTypes.NFA) and
            (Typechecker:whatType(arg2) == Metadata.dataTypes.Regex) and
            (Typechecker:whatType(arg3) == Metadata.dataTypes.Int)) then
                return nil
            else
                return "Type mismatch"
            end
end

function Typechecker:checkPredicate(predicate)
    local lines = split(predicate, " ")
    local predicate = trim(lines[1])
    local arg1 = trim(lines[2])
    local arg2 = lines[3]
    local match =  (Typechecker:whatType(arg1) == Metadata.functions[predicate].first or
                    Typechecker:whatType(arg1) == Metadata.dataTypes.DFA and
                    Metadata.functions[predicate].first == Metadata.dataTypes.NFA)
    if (arg2 ~= nil) then
        arg2 = trim(arg2)
        match =  match and (Typechecker:whatType(arg2) == Metadata.functions[predicate].second or
                    Typechecker:whatType(arg2) == Metadata.dataTypes.DFA and
                    Metadata.functions[predicate].second == Metadata.dataTypes.NFA)
    end

    if (not match) then
        return "Type mismatch"
    end

    return nil
end

function Typechecker:match(func, arg1, arg2)
    local match = Metadata.functions[func].first == Typechecker:whatType(arg1) or
                  Metadata.functions[func].first == Metadata.dataTypes.NFA and
                  Typechecker:whatType(arg1) == Metadata.dataTypes.DFA

    if (arg2 ~= nil) then
        match = match and (Metadata.functions[func].second == Typechecker:whatType(arg2) or
            Metadata.functions[func].second == Metadata.dataTypes.NFA and
            Typechecker:whatType(arg2) == Metadata.dataTypes.DFA)
    end

    return match
end




function split(line, pattern)
    local sub = {}
    local tmp = ""
    line = line .. pattern
    for i = 1, #line, 1 do
        if (line:byte(i) == pattern:byte(1)) then
            if (#tmp > 0) then
                sub[#sub + 1] = tmp
            end
            tmp = ""
        else
            tmp = tmp .. line:sub(i, i)
        end
    end
    return sub
end

function trim(line)
    local res = line
    while (res:byte(1) == 32) do
        res = res:sub(2)
    end
    while (res:byte(#res) == 32) do
        res = res:sub(1, #res - 1)
    end
    return res
end

function Typechecker:whatType(c)
    if (#c:gsub("[%d]", "") == 0) then
        return Metadata.dataTypes.Int
    elseif (identifiersList[c] ~= nil) then
        return identifiersList[c]
    else
        return Metadata.dataTypes.Regex
    end
end

return Typechecker