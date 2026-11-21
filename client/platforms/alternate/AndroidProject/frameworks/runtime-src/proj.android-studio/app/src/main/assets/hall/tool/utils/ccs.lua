
ccs.DEFAULT_TTF_FONT        = "res/fonts/FZY3JW.TTF"
-- ccs.DEFAULT_TTF_FONT        = "arial"
ccs.DEFAULT_TTF_FONT_SIZE   = 26
ccs.DEFAULT_INPUT_HOLDER    = "在这里输入"
ccs.DEFAULT_TEXTAREA_SIZE   = cc.size(40, 40)
ccs.DEFAULT_CAPINSETS       = cc.rect(0, 0, 0, 0)
ccs.DEFAULT_LAYOUT_SIZE     = cc.size(280,150)
ccs.COLOR_WHITE             = cc.c3b(255,255,255)
ccs.TEXTURE_WITH_FRAME      = 1

local function initWidget(self, params)
    local enabled = params.enabled
    local visible = params.visible
    local touchable = true
    if params.touch ~= nil then
        touchable = params.touch
    end
    local bright    = params.bright
    local foucs     = params.foucs
    local zOrder    = params.z
    local tag       = params.tag
    local color     = params.color
    local size      = params.size
    local sizeType  = params.sType
    local positionType = params.pType
    local x            = params.x or 0
    local y            = params.y or 0
    local name         = params.name

    local init = true
    
    while true
    do
        if enabled then
            init = (type(enabled) == "boolean")
            assert(init,"widget invaild params.enabled")
            if init == false then break end
            self:setEnabled(enabled)
        end

        if visible then
            init = (type(visible) == "boolean")
            assert(init,"widget invaild params.visible")
            if init == false then break end
            self:setVisible(visible)
        end

        if touchable then
            init = (type(touchable) == "boolean")
            assert(init,"widget invaild params.touch")
            if init == false then break end
            self:setTouchEnabled(touchable)
        end

        if bright then
            init = (type(bright) == "boolean")
            assert(init,"widget invaild params.bright")
            if init == false then break end
            self:setBright(bright)
        end

        if foucs then
            init = (type(foucs) == "boolean")
            assert(init,"widget invaild params.foucs")
            if init == false then break end
            self:setFocused(foucs)
        end

        if zOrder then
            init = (type(zOrder) == "number")
            assert(init,"widget invaild params.z")
            if init == false then break end
            self:setZOrder(zOrder)
        end
        
        if name then
            init = (type(name) == "string")
            assert(init,"widget invaild params.name")
            if init == false then break end
            self:setName(name)
        end

        if tag then
            init = (type(tag) == "number")
            assert(init,"widget invaild params.tag")
            if init == false then break end
            self:setTag(tag)
        end

        if color then
            init = (type(color) == "table")
            assert(init,"widget invalid params.color")
            if init == false then break end
            self:setColor(color)
        end

        if size then
            init = (type(size) == "table")
            assert(init,"widget invaild params.size")
            if init == false then break end
            self:setContentSize(size)
        end

        if sizeType then
            self:setSizeType(sizeType)
        end

        if positionType then
            self:setPositionType(positionType)
        end

        self:setPosition(x,y)

        break
    end

    return init
end


local function initLayout(self, params)
    if not params.size then params.size = ccs.DEFAULT_LAYOUT_SIZE end
    local color         = params.color
    local endColor      = params.endColor
    local colorType     = params.colorType
    local image         = params.image
    local scale9        = params.scale9
    local capInsets     = params.capInsets or ccs.DEFAULT_CAPINSETS
    local type          = params.type
    local clip          = params.clip


    local init = true
   
    while true
    do
        init = self:init(params)
        if init == false then break end

        if colorType then
            self:setBackGroundColorType(colorType)
            if colorType == LAYOUT_COLOR_GRADIENT then
                if color and endColor then
                    init = (tolua.type(color) == "ccColor3B" or tolua.type(color) == "const ccColor3B")
                    assert(init,"layout invalid params.color")
                    init = (tolua.type(endColor) == "ccColor3B")
                    assert(init,"layout invalid params.endColor")
                    if init == false then break end
                    self:setBackGroundColor(color,endColor)
                end
            else
                if color then
                    init = (tolua.type(color) == "ccColor3B" or tolua.type(color) == "const ccColor3B")
                    assert(init,"[ccs.plane] invalid params.color")
                    if init == false then break end
                    self:setBackGroundColor(color)
                end
            end
        end

        if image then
            self:setBackGroundImage(image)
        end

        if scale9 then
            self:setBackGroundImageScale9Enabled(scale9)
            self:setBackGroundImageCapInsets(capInsets)
        end

        -- layout 的布局方式
        if type then
            self:setLayoutType(type)
        end

        if clip then
            assert(type(clip) == "boolean", "[ccs.plane] invalid params.clip")
            self:setClippingEnabled(clip)
        end

        break
    end
    return init
end

function ccs.widget(params)
    assert(type(params) == "table", "[ccs.widget] invalid params")
    local widget = ccui.Widget:create()
    if initWidget(widget, params) == false then
        assert(false,"[ccs.widget] failed to initialize!")
        return nil
    end
    return widget
end

function ccs.button(params)
    assert(type(params) == "table","[ccs.button] invalid params")
    local normal    = params.normal or ""
    local pressed   = params.pressed or ""
    local disabled  = params.disabled or ""
    local scale9    = params.scale9 or false
    local capInsets = params.capInsets or ccs.DEFAULT_CAPINSETS
    local text      = params.text
    local font      = params.font or ccs.DEFAULT_TTF_FONT
    local fontSize  = params.fontSize or ccs.DEFAULT_TTF_FONT_SIZE
    local textureType = params.textureType or 0

	local button = ccui.Button:create()
    
    if initWidget(button, params) == false then
        assert(false,"[ccs.button] failed to initialize!")
        return nil
    end

    button:loadTextures(normal,pressed,disabled, textureType)

    if scale9 == true then
        if params.size then
            button:setScale9Enabled(scale9)
            button:setCapInsets(capInsets)
            button:setContentSize(params.size)
        end
    end

    if text and type(text) == "string" then
        button:setTitleText(text)
        button:setTitleFontName(font)
        button:setTitleFontSize(fontSize)
    end

    return button
end

function ccs.label(params)
    assert(type(params) == "table","[ccs.label] invalid params")
    local text      = tostring(params.text)
    local font      = params.font or ccs.DEFAULT_TTF_FONT
    local fontSize  = params.fontSize or ccs.DEFAULT_TTF_FONT_SIZE

    local label = ccui.Text:create()

    if initWidget(label, params) == false then
        assert(false,"[ccs.label] failed to initialize!")
        return nil
    end
    label:setFontName(font)
    label:setFontSize(fontSize)
    label:setString(text)

    return label
end

function ccs.labelAtlas(params)
    assert(type(params) == "table","[ccs.labelAtlas] invalid params")
    local text      = params.text or "0"
    local start     = params.start or "0"
    local image     = params.image
    assert(image and type(image) == "string", "[ccs.labelAtlas] invalid params.image")
    local width     = params.w or 1
    local height    = params.h or 1

    local labelAtlas = ccui.TextAtlas:create()
    
    if initWidget(labelAtlas, params) == false then
        assert(false,"[ccs.labelAtlas] failed to initialize!")
        return nil
    end

    if image then
        labelAtlas:setProperty(text,image,width,height,start)
    end

    return labelAtlas
end

function ccs.image(params)
    assert(type(params) == "table","[ccs.image] invalid params")
    local image = params.image
    local textureType = params.textureType or 0
    assert(image and type(image) == "string", "[ccs.image] invalid params.image")
    local imageView = ccui.ImageView:create()

    if initWidget(imageView, params) == false then
        assert(false,"[ccs.image] failed to initialize!")
        return nil
    end

    if image then
        imageView:loadTexture(image, textureType)
    end

    return imageView
end

function ccs.labelBMFont(params)
    assert(type(params) == "table","[ccs.labelBMFont] invalid params")
    local font      = params.font
    assert(font and type(font) == "string","[ccs.labelBMFont] invalid params.font")
    local text      = tostring(params.text)

    local labelBMF = ccui.TextBMFont:create()

    if initWidget(labelBMF, params) == false then
        assert(false,"[ccs.labelBMF] failed to initialize!")
        return nil
    end
    
    labelBMF:setFntFile(font)
    labelBMF:setString(text)

    return labelBMF
end

function ccs.checkBox(params)
    assert(type(params) == "table","[ccs.checkBox] invalid params")
    local normal            = params.normal
    local pressed           = params.pressed or ""
    local active            = params.active or ""
    local normal_disable    = params.n_disable or ""
    local active_disable    = params.a_disable or ""
    local textureType       = params.textureType or 0
    assert(normal and type(normal) == "string","[ccs.checkBox] invalid params.normal")
    
    local checkBox = ccui.CheckBox:create()

    if initWidget(checkBox, params) == false then
        assert(false,"[ccs.checkBox] failed to initialize!")
        return nil
    end

    checkBox:loadTextures(normal,pressed,active,normal_disable,active_disable, textureType)
    
    return checkBox
end

function ccs.slider(params)
    assert(type(params) == "table","[ccs.slider] invalid params")
    local bar_image        = params.bar or ""
    local progress         = params.progress or ""
    local ball_normal      = params.ball_n or ""
    local ball_pressed     = params.ball_p or ""
    local ball_disable     = params.ball_d or ""
    local capInsets        = params.capInsets or ccs.DEFAULT_CAPINSETS
    assert(tolua.type(capInsets) == "CCRect", "[ccs.slider] invalid params.capInsets")
    local size             = params.size

    local slider = ccui.Slider:cretae()

    if initWidget(slider, params) == false then
        assert(false,"[ccs.slider] failed to initialize!")
        return nil
    end

    slider:loadBarTexture(bar_image)
    slider:loadSlidBallTextures(ball_normal,ball_pressed,ball_disable)
    slider:loadProgressBarTexture(progress)

    --开启9宫格模式
    if size then
        slider:setScale9Enabled(true)
        slider:setCapInsets(capInsets)
        slider:setContentSize(size)
    end

    return slider
end

function ccs.loadingbar(params)
    assert(type(params) == "table","[ccs.loadingbar] invalid params")
    local image     = tostring(params.image)
    local percent   = params.percent or 100 
    local direction = params.dir
    local textureType = params.textureType or 0

    local loadingbar = ccui.LoadingBar:create()

    if initWidget(loadingbar, params) == false then
        assert(false,"[ccs.loadingbar] failed to initialize!")
        return nil
    end

    loadingbar:loadTexture(image, textureType)
    loadingbar:setPercent(percent)

    if direction then
        loadingbar:setDirection(direction)
    end

    return loadingbar
end

function ccs.textField(params)
    assert(type(params) == "table","[ccs.textField] invalid params")
    local font      = params.font or ccs.DEFAULT_TTF_FONT
    local fontSize  = params.fontSize or ccs.DEFAULT_TTF_FONT_SIZE
    local placeHolder   = params.placeHolder or ccs.DEFAULT_INPUT_HOLDER
    local maxLength = params.maxLength
    local password  = params.password or false
    local passwordText = params.passwordText or "*"

    local textField = ccui.TextField:create()

    if initWidget(textField, params) == false then
        assert(false,"[ccs.textField] failed to initialize!")
        return nil
    end

    textField:setFontName(font)
    textField:setFontSize(fontSize)
    textField:setPlaceHolder(placeHolder)

    if maxLength then
        if type(maxLength) == "number" then
            textField:setMaxLengthEnabled(true)
            textField:setMaxLength(maxLength)
        else
            assert(false,"[ccs.textField] invalid params.maxLength")
        end
    end

    if password == true then
        textField:setPasswordEnabled(true)
        textField:setPasswordStyleText(passwordText)
    end

    return textField
end

function ccs.listView(params)
    assert(type(params) == "table","[ccs.listView] invalid params")
    local direction = params.direction

    local listView = ccui.ListView:create()

    if initLayout(listView, params) == false then
        assert(false, "[ccs.listView] failed to initialize!")
        return nil
    end

    if direction then
        listView:setDirection(direction)
    end

    return listView
end

function ccs.scrollView(params)
    assert(type(params) == "table","[ccs.scrollView] invalid params")
    local direction = params.direction
    local bounce    = params.bounce
    local inertia   = params.inertia
    local innerSize = params.innerSize

    local scrollView = ccui.ScrollView:create()

    if initLayout(scrollView, params) == false then
        assert(false, "[ccs.scrollView] failed to initialize!")
        return nil
    end
    
    if direction then
        scrollView:setDirection(direction)
    end

    if bounce then
        scrollView:setBounceEnabled(bounce)
    end

    if inertia then
        scrollView:setInertiaScrollEnabled(inertia)
    end

    if innerSize then
        scrollView:setInnerContainerSize(innerSize)
    else
        scrollView:setInnerContainerSize(scrollView:getContentSize())
    end

    return scrollView
end

function ccs.pageView(params)
    assert(type(params) == "table","[ccs.pageView] invalid params")

    local pageView = ccui.PageView:create()

    if initLayout(pageView, params) == false then
        assert(false, "[ccs.pageView] failed to initialize!")
        return nil
    end

    return pageView
end

function ccs.loadWidget(filename)
	local widget = CCSWidgetExtend.extend(ccs.GUIReader:getInstance():widgetFromJsonFile(filename))
	return widget
end

function ccs.wrapNode(node)
    local wrapper = ccs.ImageView:create()
    wrapper:getVirtualRenderer():addChild(node)
    return wrapper
end

function ccs.newEditBox(params)
    params = params or {}
    local size = params.size or cc.size(100, 40)
    local background = params.background or ccui.Scale9Sprite:create()
    local backgroundType = params.backgroundType
    -- local fontName = params.fontName or DEFAULT_FONT_NAME
    local fontName = params.fontName
    local fontSize = params.fontSize or DEFAULT_FONT_SIZE
    local fontColor = params.fontColor or cc.c4b(255, 255, 255, 255)
    local maxLength = params.maxLength
    local inputMode = params.inputMode or cc.EDITBOX_INPUT_MODE_SINGLELINE
    local inputFlag = params.inputFlag 
    local placeHolder = params.placeHolder or ""
    local defaultText = params.defaultText or ""
    local editHandler = params.handler

    local editBox 
    if type(background) == "string" then 
        editBox = ccui.EditBox:create(size, background, backgroundType)
    else 
        editBox = ccui.EditBox:create(size, background)
    end
    
    editBox:setFontName(fontName)
    editBox:setPlaceholderFontName(fontName)
    editBox:setFontSize(fontSize)
    editBox:setFontColor(fontColor)
    editBox:setPlaceholderFontSize(fontSize)
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBox:setInputMode(inputMode)
    editBox:setPlaceHolder(placeHolder)
    editBox:setText(defaultText)
    if inputFlag then 
        editBox:setInputFlag(inputFlag)
    end
    if maxLength then 
        editBox:setMaxLength(maxLength)
    end
    if editHandler then 
        editBox:onEditHandler(editHandler)
    end
    return editBox
end

local function collectWalk(map, node, pattern)
    for _, child in pairs(node:getChildren()) do
        local name = child:getName()
        if not pattern or string.match(name, pattern) then
            map[name] = child
        end
        collectWalk(map, child, pattern)
    end
end

function ccs.nodeCollect(node, prefix)
    local map = {}
    local pattern = prefix and "^" .. prefix
    collectWalk(map, node, pattern)
    return map
end
