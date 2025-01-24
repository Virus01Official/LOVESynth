local Class = {}
Class.__index = Class

-- initializer
function Class:new() end

function Class:extend_as(name)
    local cls = {}
    cls["__call"] = Class.__call
    cls.__index = cls
    cls.super = self
    cls.__name = name or "AnonymousClass"
    setmetatable(cls, self)
    return cls
end

-- useful for checking if an object is of type <name>
-- ie: if obj:is("Player")
function Class:is(name)
    return self.__name == name
end

-- create a new instance by calling Namespace()
function Class:__call(...)
    local inst = setmetatable({}, self)
    inst:new(...)
    return inst
end

return Class
