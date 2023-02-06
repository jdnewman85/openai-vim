local type MyTuple = {string ,number}

local record BpeWord
  {MyTuple}
  x: number
  y: number
end

function BpeWord.new(x: number, y:number, ...:MyTuple): BpeWord
  local self: BpeWord = setmetatable({}, { __index = BpeWord })
  self.x = x
  self.y = y
  for _, tup in ipairs({...}) do
    table.insert(self, tup)
  end

  return self
end

function BpeWord:print_me()
  print("BpeWord\n")
  for i, tup in ipairs(self) do
    local inner_string = tup[1]
    local inner_number = tup[2]

    print("["..i.."]:\n"..
          "{\n"..
            "\tstring: "..inner_string.."\n"..
            "\tnumber: "..inner_number.."\n"..
          "}"
    )
  end
  print("x:"..self.x)
  print("y:"..self.y)
end

local myWord: BpeWord = BpeWord.new(4, 6, {"This", 1}, {" is", 69}, {" a", 1000}, {" test", 9999})
myWord:print_me()
