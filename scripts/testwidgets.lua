local hello = require("widgets/hello") --加载hello类
local function addHelloWidget(self)
    self.hello = self:AddChild(hello())-- 为controls添加hello widget。
    self.hello:SetHAnchor(0) -- 设置原点x坐标位置，0、1、2分别对应屏幕中、左、右
    self.hello:SetVAnchor(1) -- 设置原点y坐标位置，0、1、2分别对应屏幕中、上、下
    self.hello:SetPosition(70,-50,0) -- 设置hello widget相对原点的偏移量，70，-50表明向右70，向下50，第三个参数无意义。
end
AddClassPostConstruct("widgets/controls", addHelloWidget) -- 这个函数是官方的MOD API，用于修改游戏中的类的构造函数。
                                                        --第一个参数是类的文件路径，根目录为scripts。
                                                        --第二个自定义的修改函数，第一个参数固定为self，指代要修改的类。