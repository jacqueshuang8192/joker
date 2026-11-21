-- Pure Lua implementation of lpack-compatible string.pack / string.unpack for LuaJIT (Lua 5.1)
-- Replaces the native C lpack library that provides these functions.
-- IMPORTANT: This implements lpack's API, NOT Lua 5.3's string.pack/unpack!
--   lpack: string.pack(fmt, ...)           same as Lua 5.3
--   lpack: string.unpack(s, fmt [, init])  DIFFERENT from Lua 5.3 (s and fmt are swapped!)
-- Compatible with all format specifiers used by ByteArray.lua.

-- Bit operations: use LuaJIT's built-in bit library
local bit = require("bit")
local band, bor, bnot, lshift, rshift, tobit = bit.band, bit.bor, bit.bnot, bit.lshift, bit.rshift, bit.tobit

-- Try to use FFI for float/double conversion (much faster and more reliable)
local ffi_ok, ffi = pcall(require, "ffi")
if ffi_ok then
    ffi.cdef([[
        typedef struct { float f; } float_conv_t;
        typedef struct { double d; } double_conv_t;
    ]])
end

----------------------------------------------------------------------
-- Internal helpers
----------------------------------------------------------------------

-- Pack integer to bytes (little-endian)
local function _pack_int_le(val, size, signed)
    local bytes = {}
    for i = 0, size - 1 do
        bytes[i + 1] = string.char(band(rshift(val, i * 8), 0xFF))
    end
    return table.concat(bytes)
end

-- Pack integer to bytes (big-endian)
local function _pack_int_be(val, size, signed)
    local bytes = {}
    for i = size - 1, 0, -1 do
        bytes[i + 1] = string.char(band(rshift(val, i * 8), 0xFF))
    end
    return table.concat(bytes)
end

-- Unpack integer from bytes (little-endian)
local function _unpack_int_le(s, pos, size, signed)
    local val = 0
    for i = 0, size - 1 do
        local b = string.byte(s, pos + i) or 0
        val = val + lshift(b, i * 8)
    end
    if signed then
        local max = lshift(1, size * 8 - 1)
        if val >= max then
            val = val - lshift(1, size * 8)
        end
    end
    return val
end

-- Unpack integer from bytes (big-endian)
local function _unpack_int_be(s, pos, size, signed)
    local val = 0
    for i = 0, size - 1 do
        local b = string.byte(s, pos + i) or 0
        val = val + lshift(b, (size - 1 - i) * 8)
    end
    if signed then
        local max = lshift(1, size * 8 - 1)
        if val >= max then
            val = val - lshift(1, size * 8)
        end
    end
    return val
end

-- Pack float using FFI
local function _pack_float_le(val)
    if ffi_ok then
        local conv = ffi.new("float_conv_t")
        conv.f = val
        local ptr = ffi.cast("uint8_t*", conv)
        return string.char(ptr[0], ptr[1], ptr[2], ptr[3])
    else
        -- Fallback: manual IEEE 754
        if val ~= val then -- NaN
            return string.char(0, 0, 0xC0, 0x7F)
        elseif val == math.huge then
            return string.char(0, 0, 0x80, 0x7F)
        elseif val == -math.huge then
            return string.char(0, 0, 0x80, 0xFF)
        elseif val == 0 then
            return "\0\0\0\0"
        end
        local sign = val < 0 and 1 or 0
        val = math.abs(val)
        local exp
        if val < 1.17549435e-38 then
            exp = 0
            val = val / 1.40129846e-45
        else
            local e = math.floor(math.log(val) / 0.6931471805599453) -- log2(val)
            exp = e + 127
            if exp <= 0 then exp = 0; val = val / math.ldexp(1, 1 - 127) end
            if exp >= 255 then exp = 255; val = 0 end
            val = val / math.ldexp(1, exp - 127) - 1
        end
        local mantissa = math.floor(val * 0x800000 + 0.5)
        if mantissa >= 0x800000 then mantissa = 0; exp = exp + 1 end
        if exp >= 255 then exp = 255; mantissa = 0 end
        local bits = bor(lshift(sign, 31), lshift(exp, 23), mantissa)
        return string.char(band(bits, 0xFF), band(rshift(bits, 8), 0xFF),
                          band(rshift(bits, 16), 0xFF), band(rshift(bits, 24), 0xFF))
    end
end

local function _pack_float_be(val)
    if ffi_ok then
        local conv = ffi.new("float_conv_t")
        conv.f = val
        local ptr = ffi.cast("uint8_t*", conv)
        return string.char(ptr[3], ptr[2], ptr[1], ptr[0])
    else
        -- Fallback: use LE then reverse
        local le = _pack_float_le(val)
        return string.char(string.byte(le, 4), string.byte(le, 3), string.byte(le, 2), string.byte(le, 1))
    end
end

-- Unpack float using FFI
local function _unpack_float_le(s, pos)
    if ffi_ok then
        local conv = ffi.new("float_conv_t")
        local ptr = ffi.cast("uint8_t*", conv)
        ptr[0] = string.byte(s, pos) or 0
        ptr[1] = string.byte(s, pos + 1) or 0
        ptr[2] = string.byte(s, pos + 2) or 0
        ptr[3] = string.byte(s, pos + 3) or 0
        return conv.f
    else
        -- Fallback: manual IEEE 754
        local b0 = string.byte(s, pos) or 0
        local b1 = string.byte(s, pos + 1) or 0
        local b2 = string.byte(s, pos + 2) or 0
        local b3 = string.byte(s, pos + 3) or 0
        local bits = bor(b0, lshift(b1, 8), lshift(b2, 16), lshift(b3, 24))
        local sign = band(rshift(bits, 31), 1)
        local exp = band(rshift(bits, 23), 0xFF)
        local mantissa = band(bits, 0x7FFFFF)
        if exp == 0 then
            return 0.0
        elseif exp == 255 then
            if mantissa == 0 then return (sign == 1 and -1 or 1) * math.huge end
            return 0 / 0
        else
            local val = (1 + mantissa / 0x800000) * math.ldexp(1, exp - 127)
            return sign == 1 and -val or val
        end
    end
end

local function _unpack_float_be(s, pos)
    if ffi_ok then
        local conv = ffi.new("float_conv_t")
        local ptr = ffi.cast("uint8_t*", conv)
        ptr[3] = string.byte(s, pos) or 0
        ptr[2] = string.byte(s, pos + 1) or 0
        ptr[1] = string.byte(s, pos + 2) or 0
        ptr[0] = string.byte(s, pos + 3) or 0
        return conv.f
    else
        local b3 = string.byte(s, pos) or 0
        local b2 = string.byte(s, pos + 1) or 0
        local b1 = string.byte(s, pos + 2) or 0
        local b0 = string.byte(s, pos + 3) or 0
        local bits = bor(b0, lshift(b1, 8), lshift(b2, 16), lshift(b3, 24))
        local sign = band(rshift(bits, 31), 1)
        local exp = band(rshift(bits, 23), 0xFF)
        local mantissa = band(bits, 0x7FFFFF)
        if exp == 0 then
            return 0.0
        elseif exp == 255 then
            if mantissa == 0 then return (sign == 1 and -1 or 1) * math.huge end
            return 0 / 0
        else
            local val = (1 + mantissa / 0x800000) * math.ldexp(1, exp - 127)
            return sign == 1 and -val or val
        end
    end
end

-- Pack double using FFI
local function _pack_double_le(val)
    if ffi_ok then
        local conv = ffi.new("double_conv_t")
        conv.d = val
        local ptr = ffi.cast("uint8_t*", conv)
        return string.char(ptr[0], ptr[1], ptr[2], ptr[3], ptr[4], ptr[5], ptr[6], ptr[7])
    else
        -- Fallback: simple packing, may lose precision for non-integers
        -- Convert to string representation and pad
        return string.char(
            band(val, 0xFF), band(rshift(val, 8), 0xFF),
            band(rshift(val, 16), 0xFF), band(rshift(val, 24), 0xFF),
            0, 0, 0, 0
        )
    end
end

local function _pack_double_be(val)
    if ffi_ok then
        local conv = ffi.new("double_conv_t")
        conv.d = val
        local ptr = ffi.cast("uint8_t*", conv)
        return string.char(ptr[7], ptr[6], ptr[5], ptr[4], ptr[3], ptr[2], ptr[1], ptr[0])
    else
        return string.char(
            0, 0, 0, 0,
            band(rshift(val, 24), 0xFF), band(rshift(val, 16), 0xFF),
            band(rshift(val, 8), 0xFF), band(val, 0xFF)
        )
    end
end

-- Unpack double using FFI
local function _unpack_double_le(s, pos)
    if ffi_ok then
        local conv = ffi.new("double_conv_t")
        local ptr = ffi.cast("uint8_t*", conv)
        for i = 0, 7 do
            ptr[i] = string.byte(s, pos + i) or 0
        end
        return conv.d
    else
        local b0 = string.byte(s, pos) or 0
        local b1 = string.byte(s, pos + 1) or 0
        local b2 = string.byte(s, pos + 2) or 0
        local b3 = string.byte(s, pos + 3) or 0
        return bor(b0, lshift(b1, 8), lshift(b2, 16), lshift(b3, 24))
    end
end

local function _unpack_double_be(s, pos)
    if ffi_ok then
        local conv = ffi.new("double_conv_t")
        local ptr = ffi.cast("uint8_t*", conv)
        for i = 0, 7 do
            ptr[7 - i] = string.byte(s, pos + i) or 0
        end
        return conv.d
    else
        local b7 = string.byte(s, pos) or 0
        local b6 = string.byte(s, pos + 1) or 0
        local b5 = string.byte(s, pos + 2) or 0
        local b4 = string.byte(s, pos + 3) or 0
        return bor(lshift(b7, 24), lshift(b6, 16), lshift(b5, 8), b4)
    end
end

----------------------------------------------------------------------
-- string.pack implementation (lpack API: pack(fmt, ...))
-- Supports optional numeric repetition: e.g., "b18" = 18 bytes, "i3" = 3 ints
----------------------------------------------------------------------
function string.pack(fmt, ...)
    local args = {...}
    local arg_idx = 1
    local result = {}
    local endian_mode = "="  -- default: native
    
    local i = 1
    while i <= #fmt do
        local c = fmt:sub(i, i)
        
        if c == "<" or c == ">" or c == "=" then
            endian_mode = c
            i = i + 1
        elseif c == "A" or c == "a" then
            -- String types: digit suffix = fixed string length (A15), NOT repetition
            local num_str = ""
            local j = i + 1
            while j <= #fmt do
                local nc = fmt:sub(j, j)
                if nc:match("%d") then num_str = num_str .. nc; j = j + 1
                else break end
            end
            local val = tostring(args[arg_idx] or ""); arg_idx = arg_idx + 1
            if c == "a" then
                -- "a" format: 4-byte length prefix + string bytes
                local len_prefix = endian_mode == ">" and _pack_int_be(#val, 4, false) or _pack_int_le(#val, 4, false)
                result[#result + 1] = len_prefix
                result[#result + 1] = val
            elseif num_str ~= "" then
                -- "A<num>": fixed-length string, pad with nulls
                local len = tonumber(num_str)
                if #val < len then val = val .. string.rep("\0", len - #val) end
                result[#result + 1] = val:sub(1, len)
            else
                -- plain "A": raw string, no prefix
                result[#result + 1] = val
            end
            i = j
        elseif c == "P" then
            -- "P" format: uint16 length prefix + string (no repetition support)
            local val = tostring(args[arg_idx] or ""); arg_idx = arg_idx + 1
            local len_prefix = endian_mode == ">" and _pack_int_be(#val, 2, false) or _pack_int_le(#val, 2, false)
            result[#result + 1] = len_prefix
            result[#result + 1] = val
            i = i + 1
        else
            -- All other types: parse optional repetition count (e.g., b18, i3, h2)
            local num_str = ""
            local j = i + 1
            while j <= #fmt do
                local nc = fmt:sub(j, j)
                if nc:match("%d") then num_str = num_str .. nc; j = j + 1
                else break end
            end
            local rep = tonumber(num_str) or 1
            
            for _ = 1, rep do
                local val = args[arg_idx]; arg_idx = arg_idx + 1
                if c == "i" then  -- int32
                    result[#result + 1] = endian_mode == ">" and _pack_int_be(val, 4, true) or _pack_int_le(val, 4, true)
                elseif c == "I" then  -- uint32
                    result[#result + 1] = endian_mode == ">" and _pack_int_be(val, 4, false) or _pack_int_le(val, 4, false)
                elseif c == "h" then  -- int16
                    result[#result + 1] = endian_mode == ">" and _pack_int_be(val, 2, true) or _pack_int_le(val, 2, true)
                elseif c == "H" then  -- uint16
                    result[#result + 1] = endian_mode == ">" and _pack_int_be(val, 2, false) or _pack_int_le(val, 2, false)
                elseif c == "b" then  -- unsigned byte
                    result[#result + 1] = string.char(band(val, 0xFF))
                elseif c == "c" then  -- char (signed byte, same as unsigned for pack)
                    result[#result + 1] = string.char(band(val, 0xFF))
                elseif c == "f" then  -- float
                    result[#result + 1] = endian_mode == ">" and _pack_float_be(val) or _pack_float_le(val)
                elseif c == "n" or c == "d" then  -- lua number / double (8 bytes)
                    result[#result + 1] = endian_mode == ">" and _pack_double_be(val) or _pack_double_le(val)
                elseif c == "l" then  -- signed long (8 bytes)
                    result[#result + 1] = endian_mode == ">" and _pack_int_be(val, 8, true) or _pack_int_le(val, 8, true)
                elseif c == "L" then  -- unsigned long (8 bytes)
                    result[#result + 1] = endian_mode == ">" and _pack_int_be(val, 8, false) or _pack_int_le(val, 8, false)
                end
            end
            i = j  -- advance past the digits
        end
    end
    
    return table.concat(result)
end

----------------------------------------------------------------------
-- string.unpack implementation (lpack API: s, fmt, pos)
-- NOTE: lpack uses unpack(s, fmt [, init]), Lua 5.3 uses unpack(fmt, s [, init])
-- ByteArray.lua calls with lpack order: string.unpack(string, format)
-- lpack returns (bytes_consumed, values...), NOT (next_position, values...)
-- Supports optional numeric repetition: e.g., "b18" = 18 bytes
----------------------------------------------------------------------
function string.unpack(s, fmt, pos)
    pos = pos or 1
    local start_pos = pos
    local endian_mode = "="
    local results = {}
    
    local i = 1
    while i <= #fmt do
        local c = fmt:sub(i, i)
        
        if c == "<" or c == ">" or c == "=" then
            endian_mode = c
            i = i + 1
        elseif c == "A" or c == "a" then
            -- String types: digit suffix = fixed string length (A15), NOT repetition
            local num_str = ""
            local j = i + 1
            while j <= #fmt do
                local nc = fmt:sub(j, j)
                if nc:match("%d") then num_str = num_str .. nc; j = j + 1
                else break end
            end
            if c == "a" then
                -- "a" format: 4-byte length prefix + string
                local len = endian_mode == ">" and _unpack_int_be(s, pos, 4, false) or _unpack_int_le(s, pos, 4, false)
                pos = pos + 4
                local strval = s:sub(pos, pos + len - 1)
                results[#results + 1] = strval
                pos = pos + len
            elseif num_str ~= "" then
                -- "A<num>": fixed-length string
                local len = tonumber(num_str)
                local strval = s:sub(pos, pos + len - 1)
                results[#results + 1] = strval
                pos = pos + len
            else
                -- plain "A" (no length) — not meaningful for unpack, skip
                results[#results + 1] = ""
            end
            i = j
        elseif c == "P" then
            -- "P" format: uint16 length prefix + string (no repetition)
            local len = endian_mode == ">" and _unpack_int_be(s, pos, 2, false) or _unpack_int_le(s, pos, 2, false)
            pos = pos + 2
            local strval = s:sub(pos, pos + len - 1)
            results[#results + 1] = strval
            pos = pos + len
            i = i + 1
        else
            -- All other types: parse optional repetition count (e.g., b18, i3, h2)
            local num_str = ""
            local j = i + 1
            while j <= #fmt do
                local nc = fmt:sub(j, j)
                if nc:match("%d") then num_str = num_str .. nc; j = j + 1
                else break end
            end
            local rep = tonumber(num_str) or 1
            
            if rep > 1 and (c == "b" or c == "c") then
                -- Multi-byte/char read: pack all into one string (lpack behavior for bN/cN)
                local raw = s:sub(pos, pos + rep - 1)
                if c == "c" then
                    -- Convert each byte to signed char
                    local chars = {}
                    for k = 1, #raw do
                        local byte_val = string.byte(raw, k) or 0
                        if byte_val >= 128 then byte_val = byte_val - 256 end
                        chars[k] = byte_val
                    end
                    results[#results + 1] = chars  -- table of signed chars
                else
                    results[#results + 1] = raw  -- raw string for multi-byte
                end
                pos = pos + rep
            else
                for _ = 1, rep do
                    if c == "i" then  -- int32
                        local val = endian_mode == ">" and _unpack_int_be(s, pos, 4, true) or _unpack_int_le(s, pos, 4, true)
                        results[#results + 1] = val
                        pos = pos + 4
                    elseif c == "I" then  -- uint32
                        local val = endian_mode == ">" and _unpack_int_be(s, pos, 4, false) or _unpack_int_le(s, pos, 4, false)
                        results[#results + 1] = val
                        pos = pos + 4
                    elseif c == "h" then  -- int16
                        local val = endian_mode == ">" and _unpack_int_be(s, pos, 2, true) or _unpack_int_le(s, pos, 2, true)
                        results[#results + 1] = val
                        pos = pos + 2
                    elseif c == "H" then  -- uint16
                        local val = endian_mode == ">" and _unpack_int_be(s, pos, 2, false) or _unpack_int_le(s, pos, 2, false)
                        results[#results + 1] = val
                        pos = pos + 2
                    elseif c == "b" then  -- unsigned byte
                        results[#results + 1] = string.byte(s, pos) or 0
                        pos = pos + 1
                    elseif c == "c" then  -- signed char
                        local val = string.byte(s, pos) or 0
                        if val >= 128 then val = val - 256 end
                        results[#results + 1] = val
                        pos = pos + 1
                    elseif c == "f" then  -- float
                        local val = endian_mode == ">" and _unpack_float_be(s, pos) or _unpack_float_le(s, pos)
                        results[#results + 1] = val
                        pos = pos + 4
                    elseif c == "n" or c == "d" then  -- lua number / double
                        local val = endian_mode == ">" and _unpack_double_be(s, pos) or _unpack_double_le(s, pos)
                        results[#results + 1] = val
                        pos = pos + 8
                    elseif c == "l" then  -- signed long (8 bytes)
                        local val = endian_mode == ">" and _unpack_int_be(s, pos, 8, true) or _unpack_int_le(s, pos, 8, true)
                        results[#results + 1] = val
                        pos = pos + 8
                    elseif c == "L" then  -- unsigned long (8 bytes)
                        local val = endian_mode == ">" and _unpack_int_be(s, pos, 8, false) or _unpack_int_le(s, pos, 8, false)
                        results[#results + 1] = val
                        pos = pos + 8
                    end
                end
            end
            i = j  -- advance past the digits
        end
    end
    
    return pos - start_pos, unpack(results)
end

-- Return true to indicate module loaded successfully
return true
