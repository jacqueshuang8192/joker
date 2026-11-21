local fileOperate = class("fileOperate")

local lfs = require "lfs"
local allFilePath = {}

function fileOperate:init( ... )
    allFilePath = {}
end

function fileOperate:PrintLfsVersion( ... )
    print(lfs._VERSION)
end

function fileOperate:PrintCurrrentDir( ... )
    local rootPath = lfs.currentdir()
    print(rootPath)
end

function fileOperate:PrintDirChildren(rootPath)
    for entry in lfs.dir(rootPath) do
        if entry~='.' and entry~='..' then
            local path = rootPath.."\\"..entry
            local attr = lfs.attributes(path)
            assert(type(attr)=="table") --如果获取不到属性表则报错
            -- PrintTable(attr)
            if(attr.mode == "directory") then
                print("Dir:",path)
            elseif attr.mode=="file" then
                print("File:",path)
            end
        end
    end
end

function fileOperate:GetAllFiles(rootPath)
    allFilePath = {}
    for entry in lfs.dir(rootPath) do
        if entry~='.' and entry~='..' then
            local path = rootPath.."\\"..entry
            local attr = lfs.attributes(path)
            assert(type(attr)=="table") --如果获取不到属性表则报错
            -- PrintTable(attr)
            if(attr.mode == "directory") then
                -- print("Dir:",path)
                fileOperate:GetAllFiles(path) --自调用遍历子目录
            elseif attr.mode=="file" then
                -- print(attr.mode,path)
                table.insert(allFilePath,path)
            end
        end
    end
end

function fileOperate:GetAllLuaFiles(rootPath)

    local rootPathAttr = lfs.attributes(rootPath)

    -- dump(rootPathAttr,"rootPathAttr")

    if type(rootPathAttr) == "table" then  --
      for entry in lfs.dir(rootPath) do
          -- dump(entry,"GetAllLuaFiles_entry")
          if entry~='.' and entry~='..' then
              local path = rootPath.."\\"..entry
              local attr = lfs.attributes(path)
              assert(type(attr)=="table") --如果获取不到属性表则报错
              -- PrintTable(attr)
              if(attr.mode == "directory") then
                  -- print("Dir:",path)
                  fileOperate:GetAllLuaFiles(path) --自调用遍历子目录
              elseif attr.mode=="file"and string.find(entry,"%.lua") then
                  -- print(attr.mode,path)
                  table.insert(allFilePath,path)
              end
          end
      end
    end

    return allFilePath
end

function fileOperate:PrintTable( tbl , level, filteDefault)

  local msg = ""
  filteDefault = filteDefault or true --默认过滤关键字（DeleteMe, _class_type）
  level = level or 1
  local indent_str = ""
  for i = 1, level do
    indent_str = indent_str.."  "
  end

  print(indent_str .. "{")
  for k,v in pairs(tbl) do
    if filteDefault then
      if k ~= "_class_type" and k ~= "DeleteMe" then
        local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
        print(item_str)
        if type(v) == "table" then
          PrintTable(v, level + 1)
        end
      end
    else
      local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
      print(item_str)
      if type(v) == "table" then
        PrintTable(v, level + 1)
      end
    end
  end
  print(indent_str .. "}")
end

return fileOperate