# 打造高性能Web平台Nginx定制开发实战-Siva  


## 由 Lua 粘合的 Nginx 生态环境   
>  AJAX 化和 Service 化的趋势让所有东西开始讲 –RESTful 

## 为什么选择Nginx?  
  
* nginx 是最不烂的一个  
* 其它真心都特别烂  
* Apache 最大的问题是其 I/O 模型,无法完成非常高效的响应; 但是优点是:开发接口规整,基于它来写 mod 非常方便;
* Lighttpd 正好相反,其 I/O 非常高效,但是开发接口不怎么友好 
* Nginx 融合了两者的优点      

 > 使用了 lighttpd 多路复用的 I/O 模型   
 > 借鉴了 apache 的模块开发支持   


## 为什么 nginx 如此之快? 
 
* nginx 是单线程模型  
* 事件驱动的机制  
* I/O 多路复用     
![IO](/doc/image/anim.gif "io")     
   
 
## 为什么选择Lua

* 简单 + 轻量级(160k) + 动态性 + 高性能 + 内存开销小 + VM可中断/重入 + 可扩展性性---号称性能最高的脚本 
* 通过闭包和table可支持数据抽象，虚函数，继承和重载,面向对象编程、面向过程编程、函数式编程、自动内存管理、协程
* 用同步的语义来实现异步的调用  
* 组合优于继承的编程哲学
* Nginx无缝对接
* 充分利用 Nginx 的非阻塞 I/O 模型
* 不仅仅对 HTTP 客户端请求,甚至于对远程后端诸如MySQL,~Redis 等都进行一致的高性能响应
* Lua 脚本可与Nginx 支持的各种C以及Lua 模块非常好的互动 
* 快速构造出足以胜任 10K+ 并发连接响应的超高性能Web 应用系统 


 
## Lua 思维方式

* 最小心智负担原则      
   – 最小特性
   – 最少惊异
   – 最少犯错机会
* 少就是指数级的多 
   –最少特性原则。  
   –如果一个功能不对解决任何问题有显著价值，那么就不提供。   
* 功能内聚：组合优于继承的编程哲学
* 极度简化但完备的 OOP
* 显式表达  
  –任何封装都是有漏洞的。  
  –最佳的表达方式就是最直白的表达方式。  
  –不试图去做任何包装。   
  –所写即所得的语言。   


 
## ngx_lua 原理    

* ngx_lua实现Proactor模型    
– 业务逻辑以自然逻辑书写   
– 自然获得高并发能力   
– 不会因I/O阻塞等待而浪费CPU资源   
* 每Nginx工作进程使用一个Lua VM，工作进程内所有协程共享VM
* 将Nginx I/O原语封装后注入Lua VM，允许Lua代码直接访问
* 每个外部请求都由一个Lua协程处理，协程之间数据隔离
* Lua代码调用I/O操作接口时，若该操作无法立刻完成，则打断相关协程的运行幵保护上下文数据
* I/O操作完成时还原相关协程上下文数据并继续运行   


 
## Lua基本语法指南
### 运行环境   


<pre><code class="markdown">
[lua@vm-10-154-156-34 ~]$ lua
Lua 5.2.2  Copyright (C) 1994-2013 Lua.org, PUC-Rio
> print("Hello, World")
Hello, World
> 

/* shell一样运行： */
[lua@vm-10-154-156-34 ~]$ cat hello.lua
#!/usr/local/bin/lua
print("Hello, World")
[lua@vm-10-154-156-34 ~]$ chmod +x hello.lua
[lua@vm-10-154-156-34 ~]$ ./hello.lua
Hello, World
...
</code>
</pre>

 

### 注释  


<pre><code class="markdown">/* 单行注释 */
-- 两个减号是行注释

/* 块注释： */
--[[
 这是块注释
 这是块注释
 --]]

</code>
</pre>

 

### 变量  


<pre><code class="markdown">
Lua的数字只有double型，64bits，你不必担心Lua处理浮点数会慢（除非大于100,000,000,000,000），或是会有精度问题。

你可以以如下的方式表示数字，0x开头的16进制和C是很像的。

num = 1024
num = 3.0
num = 3.1416
num = 314.16e-2
num = 0.31416E1
num = 0xff
num = 0x56

</code>
</pre>




<pre><code class="markdown">
字符串你可以用单引号，也可以用双引号，还支持C类型的转义，比如： ‘\a’ （响铃）， ‘\b’ （退格）， ‘\f’ （表单）， ‘\n’ （换行）， ‘\r’ （回车）， ‘\t’ （横向制表）， ‘\v’ （纵向制表）， ‘\\’ （反斜杠）， ‘\”‘ （双引号）， 以及 ‘\” （单引号)

下面的四种方式定义了完全相同的字符串（其中的两个中括号可以用于定义有换行的字符串）
a = 'alo\n123"'
a = "alo\n123\""
a = '\97lo\10\04923"'
a = [[alo
123"]]

</code>
</pre>



<pre><code class="markdown">
C语言中的NULL在Lua中是nil，比如你访问一个没有声明过的变量，就是nil，

布尔类型只有nil和false是 false，数字0啊，‘’空字符串（’\0’）都是true！

另外，需要注意的是：lua中的变量如果没有特殊说明，全是全局变量，那怕是语句块或是函数里。变量前加local关键字的是局部变量。

theGlobalVar = 50
local theLocalVar = "local variable"

</code>
</pre>


### 词法约定

<pre><code class="markdown">
下面的关键字是保留的，不能用作名字：

     and       break     do        else      elseif
     end       false     for       function  if
     in        local     nil       not       or
     repeat    return    then      true      until     while
Lua 是一个大小写敏感的语言： and 是一个保留字，但是 And 和 AND 则是两个不同的合法的名字。 
一般约定，以下划线开头连接一串大写字母的名字（比如 _VERSION）被保留用于 Lua 内部全局变量。

下面这些是其它的 token ：

     +     -     *     /     %     ^     #
     ==    ~=    <=    >=    <     >     =
     (     )     {     }     [     ]
     ;     :     ,     .     ..    ...

</code>
</pre>


### 数据类型


<pre><code class="markdown">
类型	     说明
nil	     全局变量默认值，如果要删除一个全局变量可以赋值为nil
boolean	 布尔值
number	  数字型
string	  字符串型
userdata	用户自定义类型，一般是C/C++中的类型
function	函数
thread	  线程
table	   表

</code>
</pre>


 

### 逻辑运算符 


<pre><code class="markdown">
逻辑运算符认为false和nil是假（false），其他为真，0也是true.

a and b       -- 如果a为false，则返回a，否则返回b
a or  b       -- 如果a为true，则返回a，否则返回b

x = x or v    -- 如果x为false或者nil时则给x赋初始值v
-- 等价于
if not x then
    x = v
end

-- 三元运算符
a ? b : c   =>   a and b or c   -- and 的优先级别比 or 高

not                 -- not 的结果只返回false或true，作用类似于"非" "!"取反的意思
print(not nil)      -- true
print(not false)    -- true
print(not 0)        -- false
</code>
</pre>

 

### 控制结构 


<pre><code class="markdown">/* while循环 */
sum = 0
num = 1
while num <= 100 do
    sum = sum + num
    num = num + 1
end
print("sum =",sum)

</code>
</pre>


 


<pre><code class="markdown">/* for 循环 */
sum = 0
for i = 1, 100 do
    sum = sum + i
end
 

sum = 0
for i = 1, 100, 2 do
    sum = sum + i
end
 

sum = 0
for i = 100, 1, -2 do
    sum = sum + i
end

</code>
</pre>



<pre><code class="markdown">/* until循环 */
sum = 2
repeat
   sum = sum ^ 2 --幂操作
   print(sum)
until sum >1000s

</code>
</pre>

 


<pre><code class="markdown">/* if-else分支 */
if age == 16 and sex =="Female" then
    print("16岁那年追过的女孩")
elseif age > 30 and sex ~="virgin" then
    print("old Female without virgin!")
elseif age < 14 then
    io.write("too young, too naive!\n")
else
    local age = io.read()
    print("Your age is "..age)
end
上面的语句不但展示了if-else语句，也展示了
1）“～=”是不等于，而不是!=
2）io库的分别从stdin和stdout读写的read和write函数
3）字符串的拼接操作符“..”

另外，条件表达式中的与或非为分是：and, or, not关键字。

</code>
</pre>

 

### 函数-第一类值 


<pre><code class="markdown">/* 函数 */
-- Lua的函数和Python,Javascript的很像

/* 递归 */
function fib(n)
  if n < 2 then return 1 end
  return fib(n - 2) + fib(n - 1)
end

</code>
</pre>



### 闭包

<div class="columns-2">
    <pre><code class="javascript">
function newCounter()
    local i = 0
    return function() 
       i = i + 1 -- anonymous function
    return i
    end
end

c1 = newCounter()
print(c1())  --> 1
print(c1())  --> 2

    </code></pre>
    <pre><code class="javascript">
function myPower(x)
    return function(y) return y^x end
end


power2 = myPower(2)

power3 = myPower(3)


print(power2(4)) --4的2次方
print(power3(5)) --5的3次方
    </code></pre>
</div>


### 多返回值  


<pre><code class="markdown">
和Go语言一样，可以一条语句上赋多个值，如：

name, age, bGay = "luaer", 25, false, "fuhao715@gmail.com"
上面的代码中，因为只有3个变量，所以第四个值被丢弃。

函数也可以返回多个值：

function getUserInfo(id)
    print(id)
    return "luaer", 25, "fuhao715@gmail.com", "https://github.com/fuhao715"
end

name, age, email, website, bGay = getUserInfo()
注意：上面的示例中，因为没有传id，所以函数中的id输出为nil，因为没有返回bGay，所以bGay也是nil。

</code>
</pre>


### 再论函数  


<pre><code class="markdown"> 
函数前面加上local就是局部函数，其实，Lua中的函数和Python Or Javascript中的一个德行。

比如：下面的两个函数是一样的：

function foo(x) return x^2 end
foo = function(x) return x^2 end

</code>
</pre>



 

### Table


<pre><code class="markdown">

table是Lua中唯一的数据结构

lua 的 table 充当了数组和映射表的双重功能，通过组合模式可以实现面向对象编程、实现各种数据结构。--这一点和Go语言很像

</code>
</pre>

 

### Table--增删改查


<pre><code class="markdown">

所谓Table其实就是一个Key Value的数据结构，它很像Javascript中的Object，或是Python中的Dict，在别的语言里Map，Table长成这个样子：

siva = {site="http://fuhao715.github.io/", age=10, passion=True}
下面是table的CRUD操作：

siva.ceo="许QQ"  -- 增
siva.site=nil     -- 删
siva.passion = false  -- 改
local age = siva.age --查

上面看上去像Go/C中的结构体 Or Java中的Bean，但是site,age, passion, ceo都是key。

</code>
</pre>


### Table--map


<pre><code class="markdown">

还可以像下面这样写义Table：

t = {[20]=100, ['name']="Luaer", [3.14]="PI"} 
这样就更像Key Value了。于是你可以这样访问：t[20]，t[“name”], t[3.14]。


</code>
</pre>

 

### Table--数组


<pre><code class="markdown">

我们再来看看数组：

arr = {10,20,30,40,50}
这样看上去就像数组了。但其实其等价于：

arr = {[1]=10, [2]=20, [3]=30, [4]=40, [5]=50}
所以，你也可以定义成不同的类型的数组，比如：

arr = {"string", 100, "luaer", function() print("www.lua.org") end}
注：其中的函数可以这样调用：arr[4]()。


</code>
</pre>



 

### Table--矩阵（二维数组）


<pre><code class="markdown">
mt = {}                 -- 创建矩阵matrix
for i = 1, N do         -- 创建N行
    mt[i] = {}          -- 每行都是一个数组（table元素）
    for j = 1, M do     -- 创建M列
        mt[i][j] = "a"  -- 第N行第M行的值
    end
end

</code>
</pre>


 

### Table--链表


<pre><code class="markdown">
list = nil
list = {next = list, value = "hello3"}
list = {next = list, value = "hello2"}
list = {next = list, value = "hello1"}

-- 遍历
local l = list
while l do
    print(l.value)
    l = l.next
end

</code>
</pre>

 

### Table--代理模式


<pre><code class="markdown">-- 记录下表的增查记录
local index = {}                  -- 私有的key，用来记录原始表在代理表中的下标
local mt = {                      -- 创建元表
    __index = function(t, k)
        print("访问了" .. tostring(k) .. "元素")
        return t[index][k]        -- 从代理表中获取原始表中k下标的数据
    end,
    
    __newindex = function(t, k, v)
        print("更新了 " .. tostring(k) .. " 元素的值为 " .. tostring(v))
        t[index][k] = v           -- 更新代理表中下标为index的原始表中的元素
    end
}

function setProxy(t)
    local proxy = {}              -- 创建代理表
    proxy[index] = t              -- 把原始表加到代理表的index下标中
    setmetatable(proxy, mt)       -- 设置代理表的元表
    return proxy                  -- 返回代理表，即所有操作都是直接操作代理表
end

p = setProxy({})

p[2] = 'abcdefg'            -- 更新了 2 元素的值为 abcdefg
print(p[2])                 -- 访问了2元素

</code>
</pre>


 

### Table--遍历


<pre><code class="markdown">
Table的下标不是从0开始的，是从1开始的。

for i=1, #arr do  -- #表示table长度 or table.getn(arr)
    print(arr[i])
end

注：前面说过，Lua中的变量，如果没有local关键字，全都是全局变量，
Lua也是用Table来管理全局变量的，Lua把这些全局变量放在了一个叫“_G”的Table里。table.foreach(_G, print)

用如下的方式来访问一个全局变量（假设我们这个全局变量名叫globalVar）：

_G.globalVar
_G["globalVar"]
我们可以通过下面的方式来遍历一个Table。
for k, v in pairs(t) do
    print(k, v)
end

</code>
</pre>


 

### MetaTable 和 MetaMethod --元表 元方法


<pre><code class="markdown">
MetaTable主要是用来做一些类似于C++重载操作符式的功能。
比如，我们有两个分数：
fraction_a = {numerator=2, denominator=3}
fraction_b = {numerator=4, denominator=7}
我们想实现分数间的相加：2/3 + 4/7，我们如果要执行： fraction_a + fraction_b，会报错的。

所以，我们可以动用MetaTable，如下所示：
fraction_op={}
function fraction_op.__add(f1, f2)
    ret = {}
    ret.numerator = f1.numerator * f2.denominator + f2.numerator * f1.denominator
    ret.denominator = f1.denominator * f2.denominator
    return ret
end


为之前定义的两个table设置MetaTable：（其中的setmetatble是库函数）

setmetatable(fraction_a, fraction_op)
setmetatable(fraction_b, fraction_op)
于是你就可以这样干了：（调用的是fraction_op.__add()函数）

fraction_s = fraction_a + fraction_b

</code>
</pre>


 

### MetaTable 和 MetaMethod 

<pre><code class="markdown">
至于__add这是MetaMethod，这是Lua内建约定的，其它的还有如下的MetaMethod：

__add(a, b)                     对应表达式 a + b
__sub(a, b)                     对应表达式 a - b
__mul(a, b)                     对应表达式 a * b
__div(a, b)                     对应表达式 a / b
__mod(a, b)                     对应表达式 a % b
__pow(a, b)                     对应表达式 a ^ b
__unm(a)                        对应表达式 -a
__concat(a, b)                  对应表达式 a .. b
__len(a)                        对应表达式 #a
__eq(a, b)                      对应表达式 a == b
__lt(a, b)                      对应表达式 a < b
__le(a, b)                      对应表达式 a <= b
__index(a, b)                   对应表达式 a.b
__newindex(a, b, c)             对应表达式 a.b = c
__call(a, ...)                  对应表达式 a(...)

</code>
</pre>


 

### 面向对象 --通过组合实现继承

<pre><code class="markdown">
上面我们看到有__index这个重载，这个东西主要是重载了find key的操作。
这操作可以让Lua变得有点面向对象的感觉，让其有点像Javascript的prototype,python的__dict__，Go的struct

所谓__index，说得明确一点，如果我们有两个对象a和b，我们想让b作为a的prototype只需要：

setmetatable(a, {__index = b})
例如下面的示例：你可以用一个Window_Prototype的模板加上__index的MetaMethod来创建另一个实例：

Window_Prototype = {x=0, y=0, width=100, height=100}
MyWin = {title="Hello"}
setmetatable(MyWin, {__index = Window_Prototype})
于是：MyWin中就可以访问x, y, width, height的东东了。
（注：当表要索引一个值时如table[key], Lua会首先在table本身中查找key的值, 
如果没有并且这个table存在一个带有__index属性的Metatable, 则Lua会按照__index所定义的函数逻辑查找）

</code>
</pre>

 

### 面向对象--类 

<pre><code class="markdown">
Person={}
function Person:new(p)
    local obj = p
    if (obj == nil) then
        obj = {name="Luaer", age=25, handsome=true}
    end
    self.__index = self
    return setmetatable(obj, self)
end

function Person:toString()
    return self.name .." : ".. self.age .." : ".. (self.handsome and "handsome" or "ugly")
end
1）self 就是 Person，Person:new(p)，相当于Person.new(self, p)
2）new方法的self.__index = self 的意图是怕self被扩展后改写，所以，让其保持原样
3）setmetatable这个函数返回的是第一个参数的值。

</code>
</pre>



### 面向对象 --继承

<pre><code class="markdown">
me = Person:new()
print(me:toString())
luaer = Person:new{name="Luaer", age=25, handsome=false}
print(luaer:toString())
继承如下，Lua和Javascript很相似。
Student = Person:new()

function Student:new()
    newObj = {year = 2013}
    self.__index = self
    return setmetatable(newObj, self)
end

function Student:toString()
    return "Student : ".. self.year.." : " .. self.name
end

</code>
</pre>


 
### 面向对象 --私有性

<pre><code class="markdown">
local function createAccount(_name) -- 工厂方法
    local self = {name = _name}

    local function _setName(name)
        self.name = name
    end

    local function _getName()
        return self.name
    end

    -- 公有方法表
    local public = {
        setName = _setName,
        getName = _getName,
        --name = self.name -- 不公开私有成员变量
    }

    return public
end

local account = createAccount('Tom')
print(account.name) -- 无法访问，因为没有公开

</code>
</pre>



### 模块 

<pre><code class="markdown">
require(“model_name”)来载入别的lua文件，文件的后缀是.lua。载入的时候就直接执行那个文件了。比如：
注意：
1）require函数，载入同样的lua文件时，只有第一次的时候会去执行，后面的相同的都不执行了。
2）如果你要让每一次文件都会执行的话，你可以使用dofile(“hello”)函数
3）如果你要玩载入后不执行，等你需要的时候执行时，你可以使用 loadfile()函数，如下所示：
local hello = loadfile("hello")
... ...
hello()

... ...
loadfile("hello")后，文件并不执行，我们把文件赋给一个变量hello，当hello()时，才真的执行。


标准的玩法如下：
module('helloModel', package.seeall)
local HelloModel = {}

local function _hello() 
	return "hello world lua" 
end  -- 私有局部函数
 
function HelloModel.hello()
	return _hello()
end  -- 对外公开的函数
function HelloModel:getName()
	return "luaer"
end 

return HelloModel


于是我们可以这样使用：

local hello_model = require("mymod")
hello_model.hello()
print(hello_model:getName())
其实，require干的事就如下：
local hello_model = (function ()
  --mymod.lua文件的内容--
end)()
</code>
</pre>


### 错误处理和垃圾回收 

<pre><code class="markdown">
Lua 代码可以显式的调用 error 函数来产生一条错误。 
如果你需要在 Lua 中捕获发生的错误， 你可以使用 pcall 函数。
eg error():
print "enter a number:"
n = io.read("*number")
if not n then error("invalid input") end

... ...
eg error():
local status, err = pcall(function () error("my error") end)

---垃圾回收
collectgarbage()    -- 调用gc，清除引用为0的内存空间
</code>
</pre>



### 协同例程 Coroutine
----
<pre><code class="markdown"> 
-- 类似golang的goroutine
-- 创建协同
co = coroutine.create(function ()   -- 创建一个协同函数，接收一个匿名函数，返回thread类型
    print("hi")
end)

print(co)      -- thread: 0x7fe1834127d0


-- 协同的三个状态:挂起态（suspended）、运行态（running）、停止态（dead）。
print(coroutine.status(co))         -- 查看协同的状态，默认状态是挂起态 suspended

coroutine.resume(co)                -- 改变协同的状态为运行太 hi

print(coroutine.status(co))         -- 协同运行完以后将变量停止态 dead


 
-- 如此挂起正在运行的协同
co = coroutine.create(function ()
    print("hi")
    coroutine.yield()               -- 协同运行到此状态将变成挂起
    print("你好")
end)

coroutine.resume(co)                -- hi
coroutine.resume(co)                -- 你好
coroutine.resume(co)                -- false，协同结束后将不能再使用

--协同数据交换
co = coroutine.create(function (x, y)   -- 接收两个参数
    print("hi", coroutine.yield(x + y)) -- 返回一个值，同时参数也传递给了coroutine.yield
    return 100                          -- 第三种返回值的方式
end)

print(coroutine.resume(co, 12, 87))     -- 传递两个参数并接收返回值(true, 99)

-- 执行coroutine.yield(x + y)之前协同被挂起，但值被返回，因此print函数未被执行，下面执行

print(coroutine.resume(co, 12, 87))     -- 传递两个参数并接收返回值(true, 100)
</code>
</pre>



### 数学库 Mathematical Functions

<pre><code class="markdown"> 
函数	说明
math.abs (x)	求绝对值
math.acos (x)	求反余弦
math.asin (x)	
math.atan (x)	
math.atan2 (y, x)	
math.ceil (x)	
math.cos (x)	
math.cosh (x)	
math.deg (x)	
math.exp (x)	
math.floor (x)	
</code>
</pre>



### table库

<pre><code class="markdown"> 
函数	说明
table.concat (table [, sep [, i [, j]]])	拼接成字符串，sep代表连接符，i开始位置，j结束位置
table.insert (table, [pos,] value)	插入一个元素，默认是最后一个，pos指定位置
table.maxn (table)	获取最大长度
table.remove (table [, pos])	删除一个元素，默认删除最后一个，pos指定位置
table.sort (table [, comp])	排序
</code>
</pre>




 

### string库

<pre><code class="markdown"> 
函数	说明
string.byte (s [, i [, j]])	把字符转换成ASCII码
string.char (…)	把ASCII码转换成字符
string.dump (function)	
string.find (s, pattern [, init [, plain]])	查找，pattern查找的字符串，init从那里开始默认为1，plain
string.format (formatstring, …)	格式化字符串
</code>
</pre>



 

### io库

<pre><code class="markdown"> 
函数	说明
io.close ([file])	等效file:close()，如果没有file则关闭默认输出
io.flush ()	等效file:flush()
io.input ([file])	
io.lines ([filename])	等效io.input():lines()
io.open (filename [, mode])	打开一个文件，模式：r,w,a,r+,w+,a+
io.output ([file])	
io.popen (prog [, mode])	依赖系统的，不是所有平台都能用
io.read (…)	等效io.input():read
io.tmpfile ()	创建一个临时文件，当程序退出时自动删除
io.type (obj)	obj的类型是file是打开的文件句柄，close file是关闭的文件句柄，nil不是文件
io.write (…)	等效io.output():write
file:close ()	关闭文件，会自动gc掉，但时间不确定
file:flush ()	保存任何数据到文件中
file:lines ()	迭代文件的每一行
file:read (…)	读取文件，*n,*a,*l,number
file:seek ([whence] [, offset])	指定位置，默认是cur,1，set,end
file:setvbuf (mode [, size])	设置buff缓存，no,full,line
file:write (…)	写文件，参数必须是string或者number
</code>
</pre>




### os库

<pre><code class="markdown"> 
函数	说明
os.clock ()	返回程序所使用的cpu时间
os.date ([format [, time]])	当前系统日期，或格式化某个日期
os.difftime (t2, t1)	时间差
os.execute ([command])	执行shell命令
os.exit ([code])	调用C的exit函数
os.getenv (varname)	获取系统环境变量，变量名，不包含$
os.remove (filename)	删除文件，文件名
os.rename (oldname, newname)	修改文件名
os.setlocale (locale [, category])	
设置地区，"all", “collate”, “ctype”, “monetary”, “numeric”, or “time”
os.time ([table])	返回当前时间或把时间保存在table中，
os.tmpname ()	临时文件名
</code>
</pre>



 

# Nginx Lua 
> Nginx 的配置文件记法就是一种小语言  

>> location = '/hello' {   
       set_unescape_uri $person $arg_person;   
       set_if_empty $person 'anonymous';   
       echo "hello, $person!";   
   }  

>> curl 'http://localhost/hello?person=luaer'  
   hello, luaer  


 

## 添加一点儿 Lua 糖果...



 

## Nginx.conf

<pre><code class="markdown"> 
# nginx.conf
   location = /hello {
       content_by_lua '
           ngx.say("Hello World")
       ';
   }
 
</code>
</pre>


 

## 使用外部的 Lua 文件让代码保持整洁

<pre><code class="markdown"> 
# nginx.conf
   location = /hello {
       content_by_lua_file conf/hello.lua;
   }
 
</code>
</pre>




 

## Siva 框架
### 简介

> 基于OpenResty(ngx_lua)+Moochine   
> 通过upstream机制已经可以支持对mysql、redis、postgreSQL、memcached 等数据库的访问（全都是异步无阻塞的）；   
> 跟lua扩展有关的模块，提供给lua脚本调用的库，api非常丰富，涉及各种的操作；   



 


### 安装配置

* OpenResty 安装    
> 参看：http://openresty.org/#Installation 编译时选择luajit, ./configure --with-luajit   

* Siva_Nginx_lua 安装      
> Checkout Siva_Nginx_lua 代码     

* 配置环境变量     
> 
  export OPENRESTY_HOME=/usr/local/openresty     
  export SIVA_NGX_LUA_HOME=/path/to/siva_ngx_lua 
  将以上两个环境变量 加到 ~/.bash_profile 里，下次登陆自动生效      
  vim ~/.bash_profile     
  使环境变量立即生效   
  source ~/.bash_profile    


### 创建项目 

    
<pre><code class="markdown"> 
cd  /path/to/siva_ngx_lua/bin
./siva_ngx_lua  new <APP_NAME> <APP_PATH>
 
</code>
</pre>


 
### 程序目录结构  
<pre><code class="markdown" > 
siva-demo #程序根目录
|-- routing.lua # URL Routing配置
|-- application.lua # app 描述文件
|-- app #应用目录
|   `-- test.lua #请求处理函数
|-- bin #脚本目录
|   |-- debug.sh #关闭服务->清空error log->启动服务->查看error log
|   |-- reload.sh #平滑重载配置
|   |-- start.sh #启动
|   |-- stop.sh #关闭
|   |-- console.sh #控制台。注意:控制台需要安装Python2.7或Python3.2。
|   `-- cut_nginx_log_daily.sh #Nginx日志切割脚本
|-- conf  #配置目录
|    `-- nginx.conf  #Nginx配置文件模版。需要配置 `set $SIVA_APP_NAME 'siva-demo';` 为真实App的名字。
|-- appname.log.yyyy-mm-dd.log #调试日志文件。在 application.lua 可以配置路径和Level。
`-- nginx_runtime #Nginx运行时目录。这个目录下的文件由程序自动生成，无需手动管理。
    |-- conf
    |   `-- p-nginx.conf #Nginx配置文件(自动生成)，执行 ./bin/start.sh 时会根据conf/nginx.conf 自动生成。
    `-- logs #Nginx运行时日志目录
        |-- access.log #Nginx 访问日志
        |-- error.log #Nginx 错误日志
        `-- nginx.pid #Nginx进程ID文件
</code>
</pre>
</pre>


 

### 启动/停止/重载/重启 方法

    
<pre><code class="markdown"> 
./bin/start.sh #启动
./bin/stop.sh #停止
./bin/reload.sh #平滑重载配置
./bin/debug.sh #关闭服务->清空error log->启动服务->查看error log
注意：以上命令只能在程序根目录执行，类似 ./bin/xxx.sh 的方式。
</code>
</pre>


 

### 配置redis，mysql等

<pre><code class="markdown">
debug={
    on=false,
    to="response", -- "ngx.log"
}

logger = {
    file = "siva_ngx_lua_demo.log",
    level = "DEBUG",
}

redis = {
    host = "10.154.252.153",
    port = 6379,
    timeout= 10000,
    poolsize= 2000
    }

mysql= {
    host = "10.154.252.153",
    port = 3306,
    db= "taps",
    charset = "UTF8",
    username = "root",
    passwd= "siva@2014",
    timeout= 10000,
    max_packet_size= 1024*1024,
    poolsize= 2000
}
    </code></pre>    


### URL Routing：routing.lua    
    
<pre><code class="markdown"> 
#!/usr/bin/env lua
-- -*- lua -*-

local router = require('siva.router')
router.setup()

---------------------------------------------------------------------

map('^/ip%?ip=(.*)',                        'test.getIP')
</code>
</pre>



 

### 请求处理函数：app/test.lua  
    
<pre><code class="markdown"> 
module("test", package.seeall)
local JSON = require("cjson")
function getIP(req,resp)
    local exc_begin = os.time() 
    local ip = req.uri_args["ip"]
     ......
    local red = redis_conn();
    local startSet, err = red:zrevrangebyscore(key_ip_lib, offset, 0, "limit", 0, 1); 
    local startAry = string.split(startSet[1], ":");
    local ip_info = red:hmget(key_start, "country", "countryId", "area", "areaId", "region", "regionId", "city", "cityId", "isp", "ispId");    
    local result = {
        code= "A000000",
        data= {
            area= ip_info[3],
	    ................
      },
      timestamp= os.date('%Y%m%d%H%M%S', os.time())
}
    resp:writeln(JSON.encode(result))
    resp:finish()
    logger:i("-ip--last--"..(os.time()-exc_begin))
end
</code>
</pre>


 

### request对象的属性和方法

    
<pre><code class="markdown"> 
--属性
method          = ngx.var.request_method    -- http://wiki.nginx.org/HttpCoreModule#.24request_method
schema          = ngx.var.schema            -- http://wiki.nginx.org/HttpCoreModule#.24scheme
host            = ngx.var.host              -- http://wiki.nginx.org/HttpCoreModule#.24host
hostname        = ngx.var.hostname          -- http://wiki.nginx.org/HttpCoreModule#.24hostname
uri             = ngx.var.request_uri       -- http://wiki.nginx.org/HttpCoreModule#.24request_uri
path            = ngx.var.uri               -- http://wiki.nginx.org/HttpCoreModule#.24uri
filename        = ngx.var.request_filename  -- http://wiki.nginx.org/HttpCoreModule#.24request_filename
query_string    = ngx.var.query_string      -- http://wiki.nginx.org/HttpCoreModule#.24query_string
user_agent      = ngx.var.http_user_agent   -- http://wiki.nginx.org/HttpCoreModule#.24http_HEADER
remote_addr     = ngx.var.remote_addr       -- http://wiki.nginx.org/HttpCoreModule#.24remote_addr
remote_port     = ngx.var.remote_port       -- http://wiki.nginx.org/HttpCoreModule#.24remote_port
remote_user     = ngx.var.remote_user       -- http://wiki.nginx.org/HttpCoreModule#.24remote_user
remote_passwd   = ngx.var.remote_passwd     -- http://wiki.nginx.org/HttpCoreModule#.24remote_passwd
content_type    = ngx.var.content_type      -- http://wiki.nginx.org/HttpCoreModule#.24content_type
content_length  = ngx.var.content_length    -- http://wiki.nginx.org/HttpCoreModule#.24content_length

headers         = ngx.req.get_headers()     -- http://wiki.nginx.org/HttpLuaModule#ngx.req.get_headers
uri_args        = ngx.req.get_uri_args()    -- http://wiki.nginx.org/HttpLuaModule#ngx.req.get_uri_args
post_args       = ngx.req.get_post_args()   -- http://wiki.nginx.org/HttpLuaModule#ngx.req.get_post_args
socket          = ngx.req.socket            -- http://wiki.nginx.org/HttpLuaModule#ngx.req.socket

--方法
request:read_body()                         -- http://wiki.nginx.org/HttpLuaModule#ngx.req.read_body
request:get_uri_arg(name, default)
request:get_post_arg(name, default)
request:get_arg(name, default)

request:get_cookie(key, decrypt)
request:rewrite(uri, jump)                  -- http://wiki.nginx.org/HttpLuaModule#ngx.req.set_uri
request:set_uri_args(args)                  -- http://wiki.nginx.org/HttpLuaModule#ngx.req.set_uri_args
</code>
</pre>

 


### request对象的属性和方法

    
<pre><code class="markdown"> 
--属性
headers         = ngx.header                -- http://wiki.nginx.org/HttpLuaModule#ngx.header.HEADER

--方法
response:set_cookie(key, value, encrypt, duration, path)
response:write(content)
response:writeln(content)
response:ltp(template,data)
response:redirect(url, status)              -- http://wiki.nginx.org/HttpLuaModule#ngx.redirect

response:finish()                           -- http://wiki.nginx.org/HttpLuaModule#ngx.eof
response:is_finished()
response:defer(func, ...)                   -- 在response返回后执行
</code>
</pre>


 

## 思考

• 协作式调度模型的问题     
• Lua代码死循环  
• I/O操作受限于Nginx模型  
• 调试功能  

 

## Any questions?
---
https://github.com/fuhao715
emai:fuhao715@126.com
