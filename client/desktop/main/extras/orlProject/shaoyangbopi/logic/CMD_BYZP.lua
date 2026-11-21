--公共宏定义
function initGlobalDef_byzp()
    INVALID_WORD  =  0xffff               --无效数值
    INVALID_TABLE = INVALID_WORD          --无效桌子
    INVALID_CHAIR = INVALID_WORD          --无效椅子

    GAME_PLAYER   = 3                     --游戏人数
    GAME_NAME     = "邵阳剥皮"           --游戏名字

    GAME_TYPE_TANG = {"全民堂","红黑点"}
    GAME_PLAY_TYPE = {"大团圆","行行息"} 

    --性别定义
    GENDER_NULL   = 0                     --未知性别
    GENDER_BOY    = 1                     --男性性别
    GENDER_GIRL   = 2                     --女性性别

    ST_ORDER           = 0                --大小排序
    ST_COUNT           = 1                --数目排序
    FULL_COUNT         = 80               --全牌数目
    BACK_COUNT         = 1                --底牌数目
    NORMAL_COUNT       = 17               --常规数目

    --常量定义
    MAX_WEAVE          = 10                --最大组合
    MAX_INDEX          = 20               --最大索引
    MAX_COUNT          = 21               --最大数目
    MAX_REPERTORY      = 80               --最大库存
    MASK_COLOR         = 0xF0             --花色掩码
    MASK_VALUE         = 0x0F             --数值掩码

    --组合类型
    AK_NULL            = 0x00             --空
    AK_SAO_EX          = 0x01             --扫穿
    AK_SAO             = 0x02             --扫
    AK_SAO_BAD         = 0x03             --臭扫
    AK_DUO             = 0x04             --开舵
    AK_PENG            = 0x05             --碰
    AK_CHI             = 0x06             --吃
    AK_KAN             = 0x07             --坎

    --动作定义
    ACK_NULL           = 0x00             --空
    ACK_SAO_EX         = 0x01             --扫穿
    ACK_SAO            = 0x02             --扫
    ACK_CHI            = 0x04             --吃
    ACK_CHI_EX         = 0x08             --吃
    ACK_PENG           = 0x10             --碰
    ACK_DUO            = 0x20             --开舵
    ACK_CHI_HU         = 0x40             --胡

    --吃牌类型
    CK_NULL            = 0x00             --无效类型
    CK_XXD             = 0x01             --小小大搭
    CK_XDD             = 0x02             --小大大搭
    CK_EQS             = 0x04             --二七十吃
    CK_YWS             = 0x06             --一五十吃
    CK_LEFT            = 0x10             --靠左对齐
    CK_CENTER          = 0x20             --居中对齐
    CK_RIGHT           = 0x40             --靠右对齐


    --醒牌类型
    XC_NULL            = 0x00             --无效类型
    XC_OWN             = 0x01             --本醒
    CK_UP              = 0x02             --上醒
    CK_DOWN            = 0x04             --下醒
    CK_HUCARD          = 0x10             --胡牌醒

    --名堂类型
    AHK_NULL           = 0x00             --无效类型
    AHK_TIAN           = 0x01             --天胡
    AHK_DI             = 0x02             --地胡
    AHK_BLACK          = 0x03             --乌胡
    AHK_RED            = 0x04             --红胡
    AHK_OWN            = 0x05             --自摸
    AHK_TEN            = 0x06             --梗
    AHK_LUAN           = 0x07             --乱胡
    AHK_KUN            = 0x08             --昆胡
    AHK_PIAO           = 0x09             --飘
    AHK_ONE_KILL       = 0x0a             --杀报
    AHK_TWO_KILL       = 0x0b             --双杀报
    AHK_THREE_KILL     = 0x0c             --三杀报
    AHK_HAI            = 0x0d             --海底捞月
    AHK_GUI            = 0x0e             --龟


    --出牌边界线       
    OUT_CARD_LINE      = 380
end
initGlobalDef_byzp()

----------------------------位运算函数---------------------------------
bit.data32={}
for i=1,8 do
    bit.data32[i]=2^(8-i)
end

function bit:d2b(arg)
    local tr={}
    for i=1,8 do
        if arg >= bit.data32[i] then
            tr[i]=1
            arg=arg-bit.data32[i]
        else
            tr[i]=0
        end
    end
    return tr
end

function bit:b2d(arg)
    local nr=0
    for i=1,8 do
        if arg[i] ==1 then
            nr=nr+2^(8-i)
        end
    end
    return nr
end
--异或
function bit:_xor(a,b)
    local op1=self:d2b(a)
    local op2=self:d2b(b)
    local r={}
    for i=1,32 do
        if op1[i]==op2[i] then
            r[i]=0
        else
            r[i]=1
        end
    end
    return self:b2d(r)
end
--位与
function bit:_and(a,b)
    local op1=bit:d2b(a)
    local op2=bit:d2b(b)
    local r={}
    for i=1,8 do
        if op1[i]==1 and op2[i]==1 then
            r[i]=1
        else
            r[i]=0
        end
    end
    return bit:b2d(r)
end
--位或
function bit:_or(a,b)
    local op1=self:d2b(a)
    local op2=self:d2b(b)
    local r={}
    for i=1,32 do
        if op1[i]==1 or op2[i]==1 then
            r[i]=1
        else
            r[i]=0
        end
    end
    return self:b2d(r)
end
--位非
function bit:_not(a)
    local op1=self:d2b(a)
    local r={}
    for i=1,32 do
        if op1[i]==1 then
            r[i]=0
        else
            r[i]=1
        end
    end
    return self:b2d(r)
end
--右位移
function bit:_rshift(a,n)
    local op1=self:d2b(a)
    local r=self:d2b(0)
    if n < 32 and n > 0 then
        for i=1,n do
            for i=31,1,-1 do
                op1[i+1]=op1[i]
            end
            op1[1]=0
        end
    r=op1
    end
    return self:b2d(r)
end
--左位移
function bit:_lshift(a,n)
    local op1=self:d2b(a)
    local r=self:d2b(0)
    if n < 32 and n > 0 then
        for i=1,n do
            for i=1,31 do
                op1[i]=op1[i+1]
            end
            op1[32]=0
        end
    r=op1
    end
    return self:b2d(r)
end
--二进制打印
function bit:print(ta)
    local sr=""
    for i=1,32 do
        sr=sr..ta[i]
    end
    print(sr)
end

PHZStrTools = {}

function PHZStrTools.sqlitName(str)
    local _str =  cc.MyConvert:GbkToUtf8(str)  
    local ret,res = PHZStrTools.utf8Sub(_str,1,5)
    if res == true then
        ret = ret..".."
    end
    return ret
end

--截取从n到le的字符串
function PHZStrTools.utf8Sub(s, n, le)
    if s ~= nil then
        if tostring(type(s)) == "string" then
            if n ==nil then
                n = 1
            else
                if tostring(type(n)) ~= "number" or n < 1 then
                    n = 1
                end
            end 
            if le == nil then
                le = 1
            else
                if tostring(type(le)) ~= "number"  or le < 1 then
                    le = 1
                end             
            end 
            local index = 0
            local startIndex = 0 
            local endIndex = 0 
            for i = 1 , #s do

                local coding =  string.byte(s,i)
                if coding >= 128 and coding < 192 then    
                else
                    index = index + 1
                    if index == n then
                        startIndex = i
                    end
                    if index == le then
                        endIndex = i + PHZStrTools.byteNumber(coding) - 1
                    end
                 end
            end
            if index <= le then
                return s,false
            end
           return string.sub(s,startIndex,endIndex),true 
       end
    else
        return nil
    end
end 

function PHZStrTools.byteNumber(coding)
    if 127 >= coding then
        return 1
    elseif coding < 192 then
        return 0
    elseif coding < 224 then
        return 2
    elseif coding < 240 then
        return 3
    elseif coding < 248 then
        return 4
    elseif coding < 252 then
        return 5
    else
        return 6
    end
end
function PHZStrTools.GetNormalName(num)  --获取货币的简称
    if num < 10000 then
        return num
    end
    local ForwardNum = num / 10000
    if ForwardNum > 100 then
        ForwardNum = math.floor(ForwardNum)
    else
        ForwardNum = PHZStrTools.GetPreciseDecimal(ForwardNum,2)
    end
    ForwardNum = ForwardNum.."万"
    return ForwardNum
end

function PHZStrTools.GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum
    end
    n = n or 0
    n = math.floor(n)
    local fmt = '%.' .. n .. 'f'
    local nRet = tonumber(string.format(fmt, nNum))
    return nRet
end