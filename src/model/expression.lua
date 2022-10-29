local class = require("src/model/middleclass")
local RM = require("src/model/regex")
local MetaData = require("src/utils/converter_functions")

Expression = class("Expression")
Computable = class("Computable")
Test = class("Test")

local computableType = {
    variable = 0,
    func = 1,
    Int = 2,
    Regex = 3,
    DFA = 8,
    NFA = 7,
}

local expressionType = {
    computable = 0,
    test = 1,
}

local identifiersList = {}
local has = {}

function Expression:initialize(value, type)
    self.value = value
    self.type = type --Computable / Test
end

function Computable:initialize(name, type, arg1, arg2)
    self.name = name
    self.type = type
    self.arg1 = arg1
    self.arg2 = arg2
    self.typecheck = arg[1] == "-d"
    if (self.type == computableType.Int) then
        self.value = tonumber(self.name)
    elseif (self.type == computableType.Regex) then
        self.value = RM.Regex:new(self.name)
    end
end

function Computable:compute()
    if (self.value == nil) then
        if (self.type == computableType.func) then
            if (self.typecheck and not self:checkArgs()) then
                print("Type mismatch!")
                os.exit()
                return nil
            end
            if (MetaData.functions.isOverloaded[self.name]) then
                local func = self:chooseImplementation()
                if (self.arg2 == nil) then
                    self.value = func(self.arg1:compute())
                else 
                    self.value = func(self.arg1:compute(), self.arg2:compute())
                end
            else 
                if (self.arg2 == nil) then
                    self.value = MetaData.functions[self.name](self.arg1:compute())
                else
                    self.value = MetaData.functions[self.name](self.arg1:compute(), self.arg2:compute())
                end
            end
        elseif (self.type == computableType.variable) then
            if (has[self.name] ~= nil) then
                self.value = identifiersList[self.name]
            else 
                self.value = self.arg1:compute()
                identifiersList[self.name] = self.value
                has[self.name] = true
            end
        end
    end
    return self.value
end

function Computable:chooseImplementation() 
    local impl1 = nil
    local impl2 = nil
        if (self.arg1.type == computableType.func) then
            if (MetaData.functions.isOverloaded[self.arg1.name] == true) then
                if (MetaData.functions[self.name].first[1] == MetaData.functions[self.arg1.name].result[1] or
                    MetaData.functions[self.name].first[1] == MetaData.functions[self.arg1.name].result[2] or
                    MetaData.functions[self.name].first[1] == MetaData.dataTypes.NFA and
                    MetaData.functions[self.arg1.name].result[1] == MetaData.dataTypes.DFA or
                    MetaData.functions[self.name].first[1] == MetaData.dataTypes.NFA and
                    MetaData.functions[self.arg1.name].result[2] == MetaData.dataTypes.DFA) then
                        impl1 =  MetaData.functions[self.name].call[1]
                end

                if (MetaData.functions[self.name].first[2] == MetaData.functions[self.arg1.name].result[1] or
                    MetaData.functions[self.name].first[2] == MetaData.functions[self.arg1.name].result[2] or
                    MetaData.functions[self.name].first[2] == MetaData.dataTypes.NFA and
                    MetaData.functions[self.arg1.name].result[1] == MetaData.dataTypes.DFA or
                    MetaData.functions[self.name].first[2] == MetaData.dataTypes.NFA and
                    MetaData.functions[self.arg1.name].result[2] == MetaData.dataTypes.DFA) then
                        impl1 =  MetaData.functions[self.name].call[2]
                end
            else
                if (MetaData.functions[self.name].first[1] == MetaData.functions[self.arg1.name].result or
                MetaData.functions[self.name].first[1] == MetaData.dataTypes.NFA and
                MetaData.functions[self.arg1.name].result == MetaData.dataTypes.DFA) then
                    impl1 =  MetaData.functions[self.name].call[1]
                end

                if (MetaData.functions[self.name].first[2] == MetaData.functions[self.arg1.name].result or
                MetaData.functions[self.name].first[2] == MetaData.dataTypes.NFA and
                MetaData.functions[self.arg1.name].result == MetaData.dataTypes.DFA) then
                    impl1 =  MetaData.functions[self.name].call[2]
                end
            end
        else
            if (MetaData.functions[self.name].first[1] == self.arg1.type or
            MetaData.functions[self.name].first[1] == MetaData.dataTypes.NFA and
            self.arg1.type == MetaData.dataTypes.DFA) then
                impl1 =  MetaData.functions[self.name].call[1]
            end

            if (MetaData.functions[self.name].first[2] == self.arg1.type or
            MetaData.functions[self.name].first[2] == MetaData.dataTypes.NFA and
            self.arg1.type == MetaData.dataTypes.DFA) then
                impl1 =  MetaData.functions[self.name].call[2]
            end
        end

    if (self.arg2 ~= nil) then
        if (self.arg2.type == computableType.func) then
            if (MetaData.functions.isOverloaded[self.arg2.name] == true) then
                if (MetaData.functions[self.name].second[1] == MetaData.functions[self.arg2.name].result[1] or
                    MetaData.functions[self.name].second[1] == MetaData.functions[self.arg2.name].result[2] or
                    MetaData.functions[self.name].second[1] == MetaData.dataTypes.NFA and
                    MetaData.functions[self.arg2.name].result[1] == MetaData.dataTypes.DFA or
                    MetaData.functions[self.name].second[1] == MetaData.dataTypes.NFA and
                    MetaData.functions[self.arg2.name].result[2] == MetaData.dataTypes.DFA) then
                        impl2 =  MetaData.functions[self.name].call[1]
                end

                if (MetaData.functions[self.name].second[2] == MetaData.functions[self.arg2.name].result[1] or
                    MetaData.functions[self.name].second[2] == MetaData.functions[self.arg2.name].result[2] or
                    MetaData.functions[self.name].second[2] == MetaData.dataTypes.NFA and
                    MetaData.functions[self.arg2.name].result[1] == MetaData.dataTypes.DFA or
                    MetaData.functions[self.name].second[2] == MetaData.dataTypes.NFA and
                    MetaData.functions[self.arg2.name].result[2] == MetaData.dataTypes.DFA) then
                        impl2 =  MetaData.functions[self.name].call[2]
                end
            else
                if (MetaData.functions[self.name].second[1] == MetaData.functions[self.arg2.name].result or
                MetaData.functions[self.name].second[1] == MetaData.dataTypes.NFA and
                MetaData.functions[self.arg2.name].result == MetaData.dataTypes.DFA) then
                    impl2 =  MetaData.functions[self.name].call[1]
                end

                if (MetaData.functions[self.name].second[2] == MetaData.functions[self.arg2.name].result or
                MetaData.functions[self.name].second[2] == MetaData.dataTypes.NFA and
                MetaData.functions[self.arg2.name].result == MetaData.dataTypes.DFA) then
                    impl2 =  MetaData.functions[self.name].call[2]
                end
            end
        else
            if (MetaData.functions[self.name].second[1] == self.arg2.type or
            MetaData.functions[self.name].second[1] == MetaData.dataTypes.NFA and
            self.arg2.type == MetaData.dataTypes.DFA) then
                impl2 =  MetaData.functions[self.name].call[1]
            end

            if (MetaData.functions[self.name].second[2] == self.arg2.type or
            MetaData.functions[self.name].second[2] == MetaData.dataTypes.NFA and
            self.arg2.type == MetaData.dataTypes.DFA) then
                impl2 =  MetaData.functions[self.name].call[2]
            end
        end
    else
        impl1 = impl2
    end

    if (impl1 ~= impl2) then
        print("Type mismatch")
        os.exit()
    end

    return impl1
end

function Computable:checkArgs()
    if (self.arg1.type == computableType.Int and MetaData.functions[self.name].first ~= MetaData.dataTypes.Int) then
        return false
    end
    if (self.arg1.type == computableType.Regex and MetaData.functions[self.name].first ~= MetaData.dataTypes.Regex) then
        return false
    end
    if (self.arg1.type == computableType.func) then
        if (MetaData.functions.isOverloaded[self.name]) then
            if (MetaData.functions.isOverloaded[self.arg1.name]) then
                if (not (MetaData.functions[self.name].first[1] == MetaData.functions[self.arg1.name].result[1] or
                     MetaData.functions[self.name].first[1] == MetaData.functions[self.arg1.name].result[2] or
                     MetaData.functions[self.name].first[2] == MetaData.functions[self.arg1.name].result[1] or
                     MetaData.functions[self.name].first[2] == MetaData.functions[self.arg1.name].result[2] or
                     MetaData.functions[self.name].first[1] == MetaData.dataTypes.NFA and
                     MetaData.functions[self.arg1.name].result[1] == MetaData.dataTypes.DFA or
                     MetaData.functions[self.name].first[1] == MetaData.dataTypes.NFA and
                     MetaData.functions[self.arg1.name].result[2] == MetaData.dataTypes.DFA or
                     MetaData.functions[self.name].first[2] == MetaData.dataTypes.NFA and
                     MetaData.functions[self.arg1.name].result[1] == MetaData.dataTypes.DFA or
                     MetaData.functions[self.name].first[2] == MetaData.dataTypes.NFA and
                     MetaData.functions[self.arg1.name].result[2] == MetaData.dataTypes.DFA)) then
                        return false
                    end
                else
                    if (not (MetaData.functions[self.name].first[1] == MetaData.functions[self.arg1.name].result or
                    MetaData.functions[self.name].first[2] == MetaData.functions[self.arg1.name].result or
                    MetaData.functions[self.name].first[1] == MetaData.dataTypes.NFA and
                    MetaData.functions[self.arg1.name].result == MetaData.dataTypes.DFA or
                    MetaData.functions[self.name].first[2] == MetaData.dataTypes.NFA and
                    MetaData.functions[self.arg1.name].result == MetaData.dataTypes.DFA)) then
                       return false
                   end
                end
        else 
            if (MetaData.functions[self.arg1.name].result == MetaData.dataTypes.DFA and
                MetaData.functions[self.name].first == MetaData.dataTypes.NFA or
                MetaData.functions[self.arg1.name].result == MetaData.functions[self.name].first) then
                    return true
                end
            return false
        end
    end
    if (self.arg2 ~= nil) then
        if (self.arg2.type == computableType.Int and MetaData.functions[self.name].first ~= MetaData.dataTypes.Int) then
            return false
        end
        if (self.arg2.type == computableType.Regex and MetaData.functions[self.name].first ~= MetaData.dataTypes.Regex) then
            return false
        end
        if (self.arg2.type == computableType.func) then
            if (MetaData.functions.isOverloaded[self.name]) then
                if (MetaData.functions.isOverloaded[self.arg2.name]) then
                    if (not (MetaData.functions[self.name].second[1] == MetaData.functions[self.arg2.name].result[1] or
                         MetaData.functions[self.name].second[1] == MetaData.functions[self.arg2.name].result[2] or
                         MetaData.functions[self.name].second[2] == MetaData.functions[self.arg2.name].result[1] or
                         MetaData.functions[self.name].second[2] == MetaData.functions[self.arg2.name].result[2] or
                         MetaData.functions[self.name].second[1] == MetaData.dataTypes.NFA and
                         MetaData.functions[self.arg2.name].result[1] == MetaData.dataTypes.DFA or
                         MetaData.functions[self.name].second[1] == MetaData.dataTypes.NFA and
                         MetaData.functions[self.arg2.name].result[2] == MetaData.dataTypes.DFA or
                         MetaData.functions[self.name].second[2] == MetaData.dataTypes.NFA and
                         MetaData.functions[self.arg2.name].result[1] == MetaData.dataTypes.DFA or
                         MetaData.functions[self.name].second[2] == MetaData.dataTypes.NFA and
                         MetaData.functions[self.arg2.name].result[2] == MetaData.dataTypes.DFA)) then
                            return false
                        end
                    else
                        if (not (MetaData.functions[self.name].second[1] == MetaData.functions[self.arg2.name].result or
                        MetaData.functions[self.name].second[2] == MetaData.functions[self.arg2.name].result or
                        MetaData.functions[self.name].second[1] == MetaData.dataTypes.NFA and
                        MetaData.functions[self.arg2.name].result == MetaData.dataTypes.DFA or
                        MetaData.functions[self.name].second[2] == MetaData.dataTypes.NFA and
                        MetaData.functions[self.arg2.name].result == MetaData.dataTypes.DFA)) then
                           return false
                       end
                    end
            else 
                if (MetaData.functions[self.arg2.name].result == MetaData.dataTypes.DFA and
                    MetaData.functions[self.name].second == MetaData.dataTypes.NFA or
                    MetaData.functions[self.arg2.name].result == MetaData.functions[self.name].second) then
                        return true
                    end
                return false
            end
        end
    end

    return true
end

function Test:initialize(arg1, arg2, arg3)
    self.name = "Test"
    self.arg1 = arg1
    self.arg2 = arg2
    self.arg3 = arg3
end

function Test:execute()
    --Позже
    print("testing...")
    return nil
end

Expression_module = {
    expression = Expression,
    test = Test,
    computable = Computable,
    computableType = computableType,
    expressionType = expressionType,
}

return Expression_module