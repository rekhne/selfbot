-------- @RekhneSecurity
URL = require "socket.url"
http = require "socket.http"
https = require "ssl.https"
ltn12 = require "ltn12"
serpent = require ("serpent")
db = require('redis')
redis = db.connect('127.0.0.1', 6379)
JSON = require('dkjson')
tdcli = dofile("tdcli.lua")
utf8 = dofile('utf8.lua')
db = dofile('database.lua')
http.TIMEOUT = 10
local bot_id = 300162673
sudo_users = {300162673}
function is_sudo(msg)
  local var = false
  for v,user in pairs(sudo_users) do
    if user == msg.sender_user_id_ then
      var = true
    end
  end
  return var
end
function sleep(n)
  os.execute("sleep " .. tonumber(n))
end
function is_muted(user_id, chat_id)
  local var = false
  local hash = 'Self:Muted:'..chat_id
  local banned = redis:sismember(hash, user_id)
  if banned then
    var = true
  end
  return var
end
function is_fosh(msg)
  local user_id = msg.sender_user_id_
  local enemy = redis:sismember('enemy:',user_id)
  if enemy then
    return true
  end
  if not enemy then
    return false
  end
end
-------------------------------------------------------------------------------------------------------
function deleteMessagesFromUser(chat_id, user_id)
  tdcli_function ({
    ID = "DeleteMessagesFromUser",
    chat_id_ = chat_id,
    user_id_ = user_id
  }, dl_cb, nil)
end

-------------------------------------------------------------------------

----------------------------------------------------------------------------
function sendMessage(chat_id, reply_to_message_id, disable_notification, text, disable_web_page_preview, parse_mode,msg)
  local TextParseMode = getParseMode(parse_mode)
  local entities = {}
  if msg and text:match('<user>') and text:match('<user>') then
    local x = string.len(text:match('(.*)<user>'))
    local offset = x
    local y = string.len(text:match('<user>(.*)</user>'))
    local length = y
    text = text:gsub('<user>','')
    text = text:gsub('</user>','')
    table.insert(entities,{ID="MessageEntityMentionName", offset_=0, length_=2, user_id_=234458457})
  end
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = entities,
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end

------------------------------------------------------------------------
local getUser = function(user_id, cb)
tdcli_function({ID = "GetUser", user_id_ = user_id}, cb, nil)
end
local delete_msg = function(chatid, mid)
tdcli_function({
ID = "DeleteMessages",
chat_id_ = chatid,
message_ids_ = mid
}, dl_cb, nil)
end
--------------------------------------------------------------------------
function SendMetion(chat_id, user_id, msg_id, text, offset, length)
local tt = redis:get('endmsg') or ''
tdcli_function ({
ID = "SendMessage",
chat_id_ = chat_id,
reply_to_message_id_ = msg_id,
disable_notification_ = 0,
from_background_ = 1,
reply_markup_ = nil,
input_message_content_ = {
  ID = "InputMessageText",
  text_ = text..'\n\n'..tt,
  disable_web_page_preview_ = 1,
  clear_draft_ = 0,
  entities_ = {[0]={
    ID="MessageEntityMentionName",
    offset_=offset,
    length_=length,
    user_id_=user_id
  },
},
},
}, dl_cb, nil)
end
------------------------------------------------------------------------------------------------
function string:starts(text)
return text == string.sub(self, 1, string.len(text))
end

------------------------------------------------------------------------------------------------
function vardump(value)
print(serpent.block(value, {comment=false}))
end
function run(data,edited_msg)
local msg = data.message_
if edited_msg then
msg = data
end
-- vardump(msg)
local chat_id = tostring(msg.chat_id_)
local user_id = msg.sender_user_id_
local reply_id = msg.reply_to_message_id_
local caption = msg.content_.caption_

function is_added(msg)
local var = false
if redis:sismember("sgpsss:",chat_id) then
var = true
end
return var
end

if msg.chat_id_ then
local id = tostring(msg.chat_id_)
if id:match('-100(%d+)') then
chat_type = 'super'
elseif id:match('^(%d+)') then
chat_type = 'user'
else
chat_type = 'group'
end
end
local input = msg.content_.text_
if input and input:match('[QWERTYUIOPASDFGHJKLZXCVBNM]') then
input = input:lower()
end
if msg.content_.ID == "MessageText" then
Type = 'text'
if Type == 'text' and input and input:match('^[/#!]') then
input = input:gsub('^[/!#]','')
end
end
if not redis:get("typing") then
ty = '#Disable'
else
ty = '#Enable'
end
if not redis:get("markread:") then
md = '#Disable'
else
md = '#Enable'
end
if not redis:get("poker"..chat_id) then
pr = '#Disable'
else
pr = '#Enable'
end
if redis:get('autoleave:ultracreed') == "off" then
at = '#Disable'
else
at = '#Enable'
end
if not redis:get("echo:"..chat_id) then
eo = '#Disable'
else
eo = '#Enable'
end
local id = tostring(chat_id)
if id:match("-100") then
grouptype = "supergroup"
if not redis:sismember("sgpss:", chat_id) then
redis:sadd("sgpss:",chat_id)
end
elseif id:match("-") then
grouptype = "group"
if not redis:sismember("gps:", chat_id) then
redis:sadd("gps:",chat_id)
end
elseif id:match("") then
grouptype = "pv"
if not redis:sismember("pv:", chat_id) then
redis:sadd("pv:",chat_id)
end
end
redis:incr("allmsg:")
if is_muted(msg.sender_user_id_, msg.chat_id_) then
local id = msg.id_
local msgs = {[0] = id}
local chat = msg.chat_id_
tdcli.deleteMessages(chat,msgs)
return
end
if redis:get('bot:muteall'..msg.chat_id_) and not is_sudo(msg) then
local id = msg.id_
local msgs = {[0] = id}
local chat = msg.chat_id_
tdcli.deleteMessages(chat,msgs)
return
end
if not is_added(msg) then
redis:setex('time:to:leave'..chat_id, 20, true)
if redis:get('autoleave:ultracreed') == "on" and redis:get('time:to:leave'..chat_id) then
if chat_id:match('-100(%d+)') then
  if msg and not is_sudo(msg) then
    tdcli.sendText(chat_id , msg.id_, 0, 1, nil, "bay", 1, 'md')
    tdcli.changeChatMemberStatus(chat_id, tonumber(bot_id), 'Left')
  end
end
end
end

if redis:get("echo:"..chat_id) then
tdcli.forwardMessages(chat_id, chat_id,{[0] = msg.id_}, 0)
end
if msg.content_.text_ then
if input:match("^self on$") and is_sudo(msg) then
if redis:get("bot_on") then
  tdcli.editMessageText(chat_id, msg.id_, nil, '> *Self Bot Has Been Online Now !*', 1, 'md')
  redis:del("bot_on", true)
else
  tdcli.editMessageText(chat_id, msg.id_, nil, '> *The Self Bot Already On !*', 1, 'md')
end
end
if input:match("^ping$") or input:match("^Ping$") and is_sudo(msg) then
redis:sadd("sgpsss:",chat_id)
tdcli.editMessageText(chat_id, msg.id_, nil, '@RekhneSecurity', 1, 'md')
end
if input:match("^self off$") and is_sudo(msg) then
if not redis:get("bot_on") then
  tdcli.editMessageText(chat_id, msg.id_, nil, '> *Self Bot Has Been Offline Now !*', 1, 'md')
  redis:set("bot_on", true)
else
  tdcli.editMessageText(chat_id, msg.id_, nil, '> *The Self Bot Already Off !*', 1, 'md')
end
end
if input:match("^add$") or input:match("^اددی$") or input:match("^اددی پی باش$") and is_sudo(msg) and tonumber(msg.reply_to_message_id_) > 0 then
function contact(a,b,c)
  if b.content_.ID == 'MessageContact' then
    tdcli.importContacts( b.content_.contact_.phone_number_, b.content_.contact_.first_name_, (b.content_.contact_.last_name_ or ''), 0)
  end
end
tdcli.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),contact)
end
if input:match('^autoleave on$') then
tdcli.editMessageText(chat_id, msg.id_, nil, '> *Autoleave Has Been Enable !*', 1, 'md')
redis:set('autoleave:ultracreed', "on")
end
if input:match('^autoleave off$') then
tdcli.editMessageText(chat_id, msg.id_, nil, '> *Autoleave Has Been Disable !*', 1, 'md')
redis:set('autoleave:ultracreed', "off")
end
if not redis:get("bot_on") then
if is_fosh(msg) and not is_sudo(msg) then
  tdcli.sendChatAction(chat_id,'Typing')
  local data = {
    "کس کش",
    "کس ننه",
    "کص ننت",
    "کس خواهر",
    "کس خوار",
    "کس خارت",
    "کس ابجیت",
    "کص لیس",
    "ساک بزن",
    "تخخخخخخخخخ",
    "ساک مجلسی",
    "ننه الکسیس",
    "نن الکسیس",
    "ناموستو گاییدم",
    "ننه زنا",
    "😂😂😂",
    "کس خل",
    "کس مخ",
    "کس مغز",
    "کس مغذ",
    "خوارکس",
    "خوار کس",
    "خواهرکس",
    "خواهر کس",
    "حروم زاده",
    "تخخخخخخخخخ",
    "حرومزاده",
    "خار کس",
    "تخم سگ",
    "پدر سگ",
    "😂😂😂",
    "پدرسگ",
    "پدر صگ",
    "پدرصگ",
    "ننه سگ",
    "نن سگ",
    "نن صگ",
    "ننه صگ",
    "ننه خراب",
    "تخخخخخخخخخ",
    "نن خراب",
    "مادر سگ",
    "مادر خراب",
    "مادرتو گاییدم",
    "تخم جن",
    "تخم سگ",
    "😂😂😂",
    "مادرتو گاییدم",
    "ننه حمومی",
    "نن حمومی",
    "نن گشاد",
    "ننه گشاد",
    "نن خایه خور",
    "تخخخخخخخخخ",
    "نن ممه",
    "کس عمت",
    "کس کش",
    "کس بیبیت",
    "کص عمت",
    "😂😂😂",
    "کص خالت",
    "کس بابا",
    "کس خر",
    "کس کون",
    "کس مامیت",
    "کس مادرن",
    "مادر کسده",
    "خوار کسده",
    "تخخخخخخخخخ",
    "ننه کس",
    "بیناموس",
    "بی ناموس",
    "شل ناموس",
    "😂😂😂",
    "سگ ناموس",
    "ننه جندتو گاییدم باو ",
    "چچچچ نگاییدم سیک کن پلیز D:",
    "ننه حمومی",
    "چچچچچچچ",
    "😂😂😂",
    "لز ننع",
    "ننه الکسیس",
    "کص ننت",
    "بالا باش",
    "تخخخخخخخخخ",
    "ننت رو میگام",
    "کیرم از پهنا تو کص ننت",
    "مادر کیر دزد",
    "ننع حرومی",
    "تونل تو کص ننت",
    "کیرم تو کص ننت",
    "کص خوار بدخواه",
    "خوار کصده",
    "ننع باطل",
    "حروم لقمع",
    "تخخخخخخخخخ",
    "ننه سگ ناموس",
    "منو ننت شما همه چچچچ",
    "ننه کیر قاپ زن",
    "ننع اوبی",
    "چچچچچچچ",
    "ننه کیر دزد",
    "ننه کیونی",
    "ننه کصپاره",
    "زنا زادع",
    "کیر سگ تو کص نتت پخخخ",
    "ولد زنا",
    "ننه خیابونی",
    "هیس بع کس حساسیت دارم",
    "کص نگو ننه سگ که میکنمتتاااا",
    "کص نن جندت",
    "چچچچچ",
    "ننه سگ",
    "ننه کونی",
    "ننه زیرابی",
    "بکن ننتم",
    "تخخخخخخخخخ",
    "ننع فاسد",
    "ننه ساکر",
    "کس ننع بدخواه",
    "نگاییدم",
    "😂😂😂",
    "مادر سگ",
    "ننع شرطی",
    "گی ننع",
    "بابات شاشیدتت چچچچچچ",
    "ننه ماهر",
    "حرومزاده",
    "ننه کص",
    "کص ننت باو",
    "پدر سگ",
    "سیک کن کص ننت نبینمت",
    "کونده",
    "ننه ولو",
    "تخخخخخخخخخ",
    "ننه سگ",
    "مادر جنده",
    "کص کپک زدع",
    "چچچچچچچچ",
    "ننع لنگی",
    "ننه خیراتی",
    "سجده کن سگ ننع",
    "ننه خیابونی",
    "ننه کارتونی",
    "تخخخخخخخخخ",
    "تکرار میکنم کص ننت",
    "تلگرام تو کس ننت",
    "کص خوارت",
    "خوار کیونی",
    "😂😂😂",
    "پا بزن چچچچچ",
    "مادرتو گاییدم",
    "گوز ننع",
    "کیرم تو دهن ننت",
    "ننع همگانی",
    "😂😂😂",
    "کیرم تو کص زیدت",
    "کیر تو ممهای ابجیت",
    "ابجی سگ",
    "چچچچچچچچچ",
    "کس دست ریدی با تایپ کردنت چچچ",
    "ابجی جنده",
    "تخخخخخخخخخ",
    "ننع سگ سیبیل",
    "بده بکنیم چچچچ",
    "کص ناموس",
    "شل ناموس",
    "ریدم پس کلت چچچچچ",
    "ننه شل",
    "ننع قسطی",
    "ننه ول",
    "تخخخخخخخخخ",
    "دست و پا نزن کس ننع",
    "ننه ولو",
    "خوارتو گاییدم",
    "محوی!؟",
    "😂😂😂",
    "ننت خوبع!؟",
    "کس زنت",
    "شاش ننع",
    "ننه حیاطی /:",
    "نن غسلی",
    "کیرم تو کس ننت بگو مرسی چچچچ",
    "چچچچچچ",
    "ابم تو کص ننت :/",
    "فاک یور مادر خوار سگ پخخخ",
    "کیر سگ تو کص ننت",
    "کص زن",
    "ننه فراری",
    "بکن ننتم من باو جمع کن ننه جنده /:::",
    "تخخخخخخخخخ",
    "ننه جنده بیا واسم ساک بزن",
    "حرف نزن که نکنمت هااا :|",
    "کیر تو کص ننت😐",
    "کص کص کص ننت😂",
    "کصصصص ننت جووون",
    "سگ ننع",
    "😂😂😂",
    "کص خوارت",
    "کیری فیس",
    "کلع کیری",
    "تیز باش سیک کن نبینمت",
    "فلج تیز باش چچچ",
    "تخخخخخخخخخ",
    "بیا ننتو ببر",
    "بکن ننتم باو ",
    "کیرم تو بدخواه",
    "چچچچچچچ",
    "ننه جنده",
    "ننه کص طلا",
    "ننه کون طلا",
    "😂😂😂",
    "کس ننت بزارم بخندیم!؟",
    "کیرم دهنت",
    "مادر خراب",
    "ننه کونی",
    "هر چی گفتی تو کص ننت خخخخخخخ",
    "کص ناموست بای",
    "کص ننت بای ://",
    "کص ناموست باعی تخخخخخ",
    "کون گلابی!",
    "ریدی آب قطع",
    "کص کن ننتم کع",
    "نن کونی",
    "نن خوشمزه",
    "ننه لوس",
    " نن یه چشم ",
    "😂😂😂",
    "ننه چاقال",
    "ننه جینده",
    "ننه حرصی ",
    "نن لشی",
    "ننه ساکر",
    "نن تخمی",
    "ننه بی هویت",
    "نن کس",
    "نن سکسی",
    "تخخخخخخخخخ",
    "نن فراری",
    "لش ننه",
    "سگ ننه",
    "شل ننه",
    "ننه تخمی",
    "ننه تونلی",
    "😂😂😂",
    "ننه کوون",
    "نن خشگل",
    "نن جنده",
    "نن ول ",
    "نن سکسی",
    "نن لش",
    "کس نن ",
    "تخخخخخخخخخ",
    "نن کون",
    "نن رایگان",
    "نن خاردار",
    "ننه کیر سوار",
    "نن پفیوز",
    "نن محوی",
    "ننه بگایی",
    "ننه بمبی",
    "ننه الکسیس",
    "نن خیابونی",
    "نن عنی",
    "😂😂😂",
    "نن ساپورتی",
    "نن لاشخور",
    "ننه طلا",
    "ننه عمومی",
    "ننه هر جایی",
    "نن دیوث",
    "تخخخخخخخخخ",
    "نن ریدنی",
    "نن بی وجود",
    "ننه سیکی",
    "ننه کییر",
    "نن گشاد",
    "😂😂😂",
    "نن پولی",
    "نن ول",
    "نن هرزه",
    "نن دهاتی",
    "ننه ویندوزی",
    "نن تایپی",
    "نن برقی",
    "😂😂😂",
    "نن شاشی",
    "ننه درازی",
    "شل ننع",
    "یکن ننتم که",
    "کس خوار بدخواه",
    "آب چاقال",
    "ننه جریده",
    "چچچچچچچ",
    "تخخخخخخخخخ",
    "ننه سگ سفید",
    "آب کون",
    "ننه 85",
    "ننه سوپری",
    "بخورش",
    "کس ننع",
    "😂😂😂",
    "خوارتو گاییدم",
    "خارکسده",
    "گی پدر",
    "آب چاقال",
    "زنا زاده",
    "زن جنده",
    "سگ پدر",
    "مادر جنده",
    "تخخخخخخخخخ",
    "ننع کیر خور",
    "😂😂😂",
    "چچچچچ",
    "تیز بالا",
    "😂😂",
    "ننه سگو با کسشر در میره",
    "کیر سگ تو کص ننت",
  }
  tdcli.sendText(chat_id , msg.id_, 0, 1, nil, data[math.random(#data)], 1, 'md')
end
if input:match("^setenemy$") and reply_id and is_sudo(msg) then
  tdcli.sendChatAction(msg.chat_id_,'Typing')
  function setenemy_reply(extra, result, success)
    if redis:sismember("enemy:", result.sender_user_id_) then
      tdcli.editMessageText(chat_id, msg.id_, nil, '> *This User Already Is Enemy !*', 1, 'md')
    else
      redis:sadd("enemy:", result.sender_user_id_) tdcli.editMessageText(chat_id, msg.id_, nil, '> User : <user>'.. result.sender_user_id_ ..'</user> Has Been Set To Enemy Users !', 1, nil, result.sender_user_id_ )
    end
  end
  tdcli.getMessage(chat_id,msg.reply_to_message_id_,setenemy_reply,nil)
elseif input:match("^setenemy @(.*)$") and is_sudo(msg) then
  tdcli.sendChatAction(msg.chat_id_,'Typing')
  function setenemy_username(extra, result, success)
    if result.id_ then
      if redis:sismember('enemy:', result.id_) then
        tdcli.editMessageText(chat_id, msg.id_, nil, '> *This User Already Is Enemy !*', 1, 'md')
      else
        redis:sadd("enemy:", result.id_)
        tdcli.editMessageText(chat_id, msg.id_, nil, '> User : <user>'..result.id_..'</user> Has Been Set To Enemy Users !', 1, nil)
      end
    else
      tdcli.editMessageText(chat_id, msg.id_, nil, '> *User Not Found *', 1, 'md')
    end
  end
  tdcli.searchPublicChat(input:match("^setenemy @(.*)$"),setenemy_username)
elseif input:match("^setenemy (%d+)$") and is_sudo(msg) then
  tdcli.sendChatAction(chat_id,'Typing')
  if redis:sismember('enemy:', input:match("^setenemy (%d+)$")) then
    tdcli.editMessageText(chat_id, msg.id_, nil, '> *This User Already Is Enemy !*', 1, 'md')
  else
    redis:sadd('enemy:', input:match("^setenemy (%d+)$"))
    tdcli.editMessageText(chat_id, msg.id_, nil, '> User : <user>'..input:match("^setenemy (%d+)$")..'</user> Has Been Set To Enemy Users !', 1, nil)
  end
end
if input:match("^delenemy$") and reply_id and is_sudo(msg) then
  tdcli.sendChatAction(msg.chat_id_,'Typing')
  function remenemy_reply(extra, result, success)
    if not redis:sismember("enemy:", result.sender_user_id_) then
      tdcli.editMessageText(chat_id, msg.id_, nil, '> *This Is Not A Enemy Users !*', 1, nil)
    else
      redis:srem("enemy:", result.sender_user_id_)
      tdcli.editMessageText(chat_id, msg.id_, nil, '> User : <user>'..result.sender_user_id_..'</user> Removed From Enemy Users !', 1, nil)
    end
  end
  tdcli.getMessage(chat_id,msg.reply_to_message_id_,remenemy_reply,nil)
elseif input:match("^delenemy @(.*)$") and is_sudo(msg) then
  tdcli.sendChatAction(msg.chat_id_,'Typing')
  function remenemy_username(extra, result, success)
    if result.id_ then
      if not redis:sismember('enemy:', result.id_) then
        tdcli.editMessageText(chat_id, msg.id_, nil, '> *This Is Not A Enemy Users !*', 1, nil)
      else
        redis:srem('enemy:', result.id_)
        tdcli.editMessageText(chat_id, msg.id_, nil, '> User : <user>'..result.id_..'</user> Removed From Enemy Users !', 1, nil)
      end
    else
      tdcli.editMessageText(chat_id, msg.id_, nil, '> *User Not Found *', 1, 'md')
    end
  end
  tdcli.searchPublicChat(input:match("^delenemy @(.*)$"),remenemy_username)
elseif input:match("^delenemy (%d+)$") and is_sudo(msg) then
  tdcli.sendChatAction(msg.chat_id_,'Typing')
  if not redis:sismember('enemy:', input:match("^delenemy (%d+)$")) then
    tdcli.editMessageText(chat_id, msg.id_, nil, '> *This Is Not A Enemy Users !*', 1, 'md')
  else
    redis:srem('enemy:', input:match("^delenemy (%d+)$"))
    tdcli.editMessageText(chat_id, msg.id_, nil, '> User : <user>'..input:match("^delenemy (%d+)$")..'</user> Removed From Enemy Users !', 1, nil)
  end
elseif input:match("^enemylist$") and is_sudo(msg) then
  tdcli.sendChatAction(msg.chat_id_,'Typing')
  local text = "*Enemy List :*\n\n"
  for k,v in pairs(redis:smembers('enemy:')) do
    text = text.."*"..k.."* - `"..v.."`\n"
  end
  tdcli.editMessageText(chat_id, msg.id_, nil, text, 1, 'md')
elseif input:match("^clean enemylist$") and is_sudo(msg) then
  redis:del('enemy:')
  tdcli.editMessageText(chat_id, msg.id_, nil, '*Done ...!*\n*Enemy List Has Been Removed.*', 1, 'md')
end
if input:match("^inv$") and reply_id and is_sudo(msg) then
  function inv_reply(extra, result, success)
    tdcli.addChatMember(chat_id, result.sender_user_id_, 20)
    end tdcli.getMessage(chat_id,msg.reply_to_message_id_,inv_reply,nil)
  elseif input:match("^inv @(.*)$") and is_sudo(msg) then
    function inv_username(extra, result, success)
      if result.id_ then
        tdcli.addChatMember(chat_id, result.id_, 20)
      else
        tdcli.editMessageText(chat_id, msg.id_, nil,'*User Not Found :(*', 1, 'md')
      end
    end
    tdcli.searchPublicChat(input:match("^inv @(.*)$"),inv_username)
  elseif input:match("^inv (%d+)$") and is_sudo(msg) then
    tdcli.addChatMember(chat_id, input:match("^inv @(.*)$"), 20)
    end
    if input:match("^kick$") and reply_id and is_sudo(msg) then
      tdcli.sendChatAction(msg.chat_id_,'Typing')
      function kick_reply(extra, result, success)
        tdcli.changeChatMemberStatus(chat_id, result.sender_user_id_, 'Kicked')
        tdcli.editMessageText(chat_id, msg.id_, nil, '> *User :* `'..result.sender_user_id_..'` *Has Been Kicked !*', 1, 'md')
        end tdcli.getMessage(chat_id,msg.reply_to_message_id_,kick_reply,nil)
      elseif input:match("^kick @(.*)$") and is_sudo(msg) then
        tdcli.sendChatAction(msg.chat_id_,'Typing')
        function kick_username(extra, result, success)
          if result.id_ then
            tdcli.changeChatMemberStatus(chat_id, result.id_, 'Kicked')
            tdcli.editMessageText(chat_id, msg.id_, nil, '> *User :* `'..result.id_..'` *Has Been Kicked !*', 1, 'md')
          else
            tdcli.editMessageText(chat_id, msg.id_, nil, '> *User Not Found :(*', 1, 'html')
          end
        end
        tdcli.searchPublicChat(input:match("^kick @(.*)$"),kick_username)
      elseif input:match("^kick (%d+)$") and is_sudo(msg) then
        tdcli.sendChatAction(msg.chat_id_,'Typing')
        tdcli.changeChatMemberStatus(chat_id, input:match("^kick (%d+)$"), 'Kicked')
        tdcli.editMessageText(chat_id, msg.id_, nil, '> *User :* `'..input:match("^kick (%d+)$")..'` *Has Been Kicked !*', 1, 'md')
      end
      if input:match("^typing on$") and is_sudo(msg) then
        if not redis:get("typing") then
          redis:set("typing", true)
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *Typing Mode Has Been Turned on !*', 1, 'md')
        else
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *Typing Mode Is Already On !*', 1, 'md')
        end
      end
      if input:match("^typing off$") and is_sudo(msg) then
        if redis:get("typing") then
          redis:del("typing", true)
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *Typing Mode Has Been Off !*', 1, 'md')
        else
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *Typing Mode Is Already Off !*', 1, 'md')
        end
      end
      if redis:get("typing") then
        tdcli.sendChatAction(chat_id,'Typing')
      end
      if input:match("^markread on$") and is_sudo(msg) then
        if not redis:get("markread:") then
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *MarkRead Has Been On !*', 1, 'md')
          redis:set("markread:", true)
        else
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *MarkRead Is Already On !*', 1, 'md')
        end
      end
      if input:match("^markread off$") and is_sudo(msg) then
        if redis:get("markread:") then
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *MarkRead Has Been Off Now !*', 1, 'md')
          redis:del("markread:", true)
        else
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *MarkRead Is Already Off !*', 1, 'md')
        end
      end
      if redis:get("markread:") then
        tdcli.viewMessages(chat_id, {[0] = msg.id_})
      end
      if input:match("^poker on$") and is_sudo(msg) then
        if not redis:get("poker"..chat_id) then
          redis:set("poker"..chat_id, true)
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *Poker Msg Has Been Enable !*', 1, 'md')
        else
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *Poker Msg Is Already Enable !*', 1, 'md')
        end
      end

      if input:match('^(.*) @(.*)$') then
        if is_sudo(msg) then
          local apen = {
            string.match(input, '^(.*) @(.*)$')}
            local text = apen[1]
            local m_username = function(extra, result)
            if result.id_ then
              tdcli.deleteMessages(chat_id, {[0] = msg.id_})
              SendMetion(msg.chat_id_, result.id_, msg.id_, text, 0, utf8.len(text))
            end
          end
          tdcli.searchPublicChat(apen[2],m_username)
        end
      end
      if input:match("^poker off$") and is_sudo(msg) then
        if redis:get("poker"..chat_id) then
          redis:del("poker"..chat_id, true)
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *Poker Msg Has Been Disable !*', 1, 'md')
        else
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *Poker Msg Is Already Disable !*', 1, 'md')
        end
      end
      if redis:get("poker"..chat_id) then
        if input:match("^😐$") and not is_sudo(msg) and not redis:get("time_poker"..user_id) then
          local text = '😐'
          SendMetion(msg.chat_id_, msg.sender_user_id_, msg.id_, text, 0, 4)
          redis:setex("time_poker"..user_id, 4, true)
        end
      end
      if input:match("^left$") and is_sudo(msg) then
        redis:srem("sgpsss:",chat_id)
        tdcli.editMessageText(chat_id, msg.id_, nil, '*Done ...!*', 1, 'md')
        tdcli.changeChatMemberStatus(chat_id, user_id, 'Left')
      end

      if input:match('^(setanswer) "(.*)" "(.*)"$') then
        local ans = {string.match(input, '^(setanswer) "(.*)" "(.*)"$')}
        redis:hset("answer", ans[2], ans[3])
        text = "<b>Your Text for Command : "..ans[2].." Has been Successfully Set !</b>"
        tdcli.editMessageText(chat_id, msg.id_, nil, text, 1, 'html')
      end
      if input:match("^(delanswer) (.*)") then
        local matches = input:match("^delanswer (.*)")
        redis:hdel("answer", matches)
        text = "<b>Your Text for Command : "..matches.." Has been Removed !</b>"
        tdcli.editMessageText(chat_id, msg.id_, nil, text, 1, 'html')
      end
      if input:match("^answerlist$") and is_sudo(msg) then
        tdcli.sendChatAction(msg.chat_id_,'Typing')
        local text = "*Answer List :*\n\n"
        for k,v in pairs(redis:hkeys("answer")) do
          local value = redis:hget("answer", v)
          text = text..""..k.."- "..v.." => "..value.."\n"
        end
        tdcli.editMessageText(chat_id, msg.id_, nil, text, 1, 'md')
      end
      if input:match("^clean answerlist$") and is_sudo(msg) then
        redis:del("answer")
        tdcli.editMessageText(chat_id, msg.id_, nil, '*Done ...!*\n*Answer List Has Been Removed.*', 1, 'md')
      end
      if input:match("^answer on$") and is_sudo(msg) then
        if not redis:get("autoanswer") then
          redis:set("autoanswer", true)
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *Answer Has Been Enable !*', 1, 'md')
        else
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *Answer Is Already Enable !*', 1, 'md')
        end
      end
      if input:match("^answer off$") and is_sudo(msg) then
        if redis:get("autoanswer") then
          redis:del("autoanswer")
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *Answer Has Been Disable !*', 1, 'md')
        else
          tdcli.editMessageText(chat_id, msg.id_, nil, '> *Answer Is Already Disable !*', 1, 'md')
        end
      end
      if redis:get("autoanswer") then
        if msg.sender_user_id_ ~= bot_id then
          local names = redis:hkeys("answer")
          for i=1, #names do
            if input == names[i] then
              local value = redis:hget("answer", names[i])
              tdcli.sendText(chat_id, msg.id_, 0, 1, nil, value, 1, 'md')
            end
          end
        end
      end

      if input:match("^myid$") and is_sudo(msg) then
        tdcli.sendChatAction(msg.chat_id_,'Typing')
        tdcli.editMessageText(chat_id, msg.id_, nil, '`'..user_id..'`', 1, 'md')
      elseif input:match("^id$") and reply_id ~= 0 and is_sudo(msg) then
        tdcli.sendChatAction(msg.chat_id_,'Typing')
        function id_reply(extra, result, success)
          tdcli.editMessageText(chat_id, msg.id_, nil, '`'..result.sender_user_id_..'`', 1, 'md')
        end
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,id_reply,nil)
      elseif input:match("^id @(.*)$") and is_sudo(msg) then
        function id_username(extra, result, success)
          if result.id_ then
            tdcli.editMessageText(chat_id, msg.id_, nil, '`'..result.id_..'`', 1, 'md')
          else
            tdcli.editMessageText(chat_id, msg.id_, nil, '*User Not Found :(*', 1, 'md')
          end
        end
        tdcli.searchPublicChat(input:match("^id @(.*)$"),id_username)
      end
      if input:lower() == 'cm' and is_sudo(msg) then
        x = 0
        while x < 4 do
          function cleanmembers(extra, result, success)
            print(serpent.block(result,{comment=false}))
            for k, v in pairs(result.members_) do
              local members = v.user_id_
              if members ~= bot_id then
                tdcli.changeChatMemberStatus(chat_id, v.user_id_, 'Kicked')
                print("kicked all members")
              end
            end
          end
          tdcli.getChannelMembers(chat_id, "Recent", 0, 200, cleanmembers, nil)
          x = x + 1
        end
      end
      if input:match("^cmsg$") and is_sudo(msg) then
        local rm = 1000
        local function del_msg(extra, result, success)
          for k, v in pairs(result.messages_) do
            tdcli.deleteMessages(msg.chat_id_,{[0] = v.id_})
          end
        end
        tdcli.getChatHistory(msg.chat_id_, 0, 0, tonumber(rm), del_msg, nil)
      end
      if input:match("^cmsg$") and is_sudo(msg) then
        function cms(extra, result, success)
          for k, v in pairs(result.members_) do
            deleteMessagesFromUser(chat_id, v.user_id_)
          end
          tdcli.editMessageText(chat_id, msg.id_, nil, 'All Msg Cleaned', 1, 'md')
        end
        tdcli.getChannelMembers(chat_id, "Recent", 0, 2000, cms, nil)
        tdcli.getChannelMembers(chat_id, "Administrators", 0, 2000, cms, nil)
        tdcli.getChannelMembers(chat_id, "Bots", 0, 2000, cms, nil)
        tdcli.getChannelMembers(chat_id, "Kicked", 0, 2000, cms, nil)
      end
      if input:match("^sos$") and is_sudo(msg) then
        tdcli.addChatMember(chat_id, 309573480, 0)
        tdcli.addChatMember(chat_id, 194849320, 0)
        tdcli.addChatMember(chat_id, 114900277, 0)
        tdcli.addChatMember(chat_id, 449389567, 0)
        tdcli.addChatMember(chat_id, 309573480, 0)
        tdcli.addChatMember(chat_id, 276281882, 0)
        tdcli.addChatMember(chat_id, 399574034, 0)
        tdcli.addChatMember(chat_id, 388551242, 0)
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
      if input:match("^‌(.*)$") and is_is_sudo(msg) then
        for i=1, 30 do
          tdcli.forwardMessages(chat_id, chat_id,{[0] = msg.id_}, 0)
        end
      end
      if input:match("^echo on$") and is_sudo(msg) then
        if redis:get("echo:"..chat_id) then
          tdcli.editMessageText(chat_id, msg.id_, nil,'*Text Repeat Mode Was Enabled*',1,'md')
        else
          redis:set("echo:"..chat_id, true)
          tdcli.editMessageText(chat_id, msg.id_, nil,'*Text Repeat Mode Enabeled*',1,'md')
        end
      elseif input:match("^echo off$") and is_sudo(msg) then
        if not redis:get("echo:"..chat_id) then
          tdcli.editMessageText(chat_id, msg.id_, nil,'*Text Repeat Mode Was Disabled*',1,'md')
        else
          redis:del("echo:"..chat_id)
          tdcli.editMessageText(chat_id, msg.id_, nil,'*Text Repeat Mode Disabled*',1,'md')
        end
      end
      if input:match("^del (%d+)") then
        local rm = tonumber(input:match("^del (%d+)"))
        if is_sudo(msg) then
          if rm < 101 then
            local function del_msg(extra, result, success)
              local num = 0
              local message = result.messages_
              for i=0 , #message do
                num = num + 1
                tdcli.deleteMessages(msg.chat_id_,{[0] = message[i].id_})
              end
              tdcli.editMessageText(chat_id, msg.id_, nil, '#Done\n`'..num..'` *Msgs Has Been Cleared.*', 1, 'md')
            end
            tdcli.getChatHistory(msg.chat_id_, 0, 0, tonumber(rm), del_msg, nil)
          else
            tdcli.editMessageText(chat_id, msg.id_, nil, '*just [1-100]*', 1, 'md')
          end
        end
      end
      if input:match("^delall$") and is_sudo(msg) and msg.reply_to_message_id_ then
        function tlg_del_all(extra, result, success)
          tdcli.editMessageText(chat_id, msg.id_, nil, '#Done\n*All Msgs from * `'..result.sender_user_id_..'` *Has been deleted!*', 1, 'md')
          tdcli.deleteMessagesFromUser(result.chat_id_, result.sender_user_id_)
        end
        tdcli.getMessage(msg.chat_id_, msg.reply_to_message_id_,tlg_del_all)
      end
      if input:match("^delall (%d+)$") and is_sudo(msg) then
        local tlg = {string.match(txt, "^(delall) (%d+)$")}
        tdcli.deleteMessagesFromUser(msg.chat_id_, tlg[2])
        tdcli.editMessageText(chat_id, msg.id_, nil, '#Done\n>b>All Msg From user>/b> >code>'..tlg[2]..'>/code> >b>Deleted!>/b>', 1, 'html')
      end
      if input:match("^delall @(.*)$") and is_sudo(msg) then
        local tlg = {string.match(txt, "^(delall) @(.*)$")}
        function tlg_del_user(extra, result, success)
          if result.id_ then
            tdcli.deleteMessagesFromUser(msg.chat_id_, result.id_)
            text = '<b>#Done\nAll Msg From user</b> <code>'..result.id_..'</code> <b>Deleted</b>'
          else
            text = '>b>User Not found!>/b>'
          end
          tdcli.editMessageText(chat_id, msg.id_, nil, text, 1, 'html')
        end
        tdcli.searchPublicChat(tlg[2],tlg_del_user)
      end
      if input:match("^stats$") and is_sudo(msg) then
        local gps = redis:scard("gps:")
        local users = redis:scard("pv:")
        local allmgs = redis:get("allmsg:")
        local sgps = redis:scard("sgpss:")
        tdcli.editMessageText(chat_id, msg.id_, nil, '*> Self Bot Stats* :\n\n*> SuperGroups* : `'..sgps..'`\n*> Groups* : `'..gps..'`\n\n*> Users* : `'..users..'`\n*> SelfBot All Msg* : `'..allmgs..'`', 1, 'md')
      end
      if input:match("^pin$") and is_sudo(msg) then
        local id = msg.id_
        local msgs = {[0] = id}
        tdcli.pinChannelMessage(msg.chat_id_,msg.reply_to_message_id_,0)
        tdcli.editMessageText(chat_id, msg.id_, nil, '#Done\n*Msg han been pinned!*', 1, 'md')
        redis:set('#Done\npinnedmsg'..msg.chat_id_,msg.reply_to_message_id_)
      end
      if input:match("^unpin$") and is_sudo(msg) then
        tdcli.unpinChannelMessage(msg.chat_id_)
        tdcli.editMessageText(chat_id, msg.id_, nil, '#Done\n*Pinned Msg han been unpinned!*', 1, 'md')
      end
      if input:match("^gpid$") and is_sudo(msg) then
        tdcli.editMessageText(chat_id, msg.id_, nil, '`'..msg.chat_id_..'`', 1, 'html')
      end
      if input:match("^muteall (%d+)$") and is_sudo(msg) then
        local mutetlg = {string.match(txt, "^mute all (%d+)$")}
        redis:setex('bot:muteall'..msg.chat_id_, tonumber(mutetlg[1]), true)
        tdcli.editMessageText(chat_id, msg.id_, nil, '#Done\n*Group muted for* `'..mutetlg[1]..'` *Seconds!*', 1, 'md')
      end
      if input:match("^unmuteall$") and is_sudo(msg) then
        tdcli.editMessageText(chat_id, msg.id_, nil, '#Done\n*Mute All has Been Disabled*', 1, 'md')
        redis:del('bot:muteall'..msg.chat_id_)
      end
    end
    if input:match("^fwd (.*)") and msg.reply_to_message_id_ ~= 0 and is_sudo(msg) then
      local action = input:match("^fwd (.*)")
      if action == "sgps" then
        local gp = redis:smembers('sgpss:') or 0
        local gps = redis:scard('sgpss:') or 0
        for i=1, #gp do
          sleep(0.5)
          tdcli.forwardMessages(gp[i], chat_id,{[0] = reply_id}, 0)
        end
        tdcli.editMessageText(chat_id, msg.id_, nil, '*Your message was forwarded to '..gps..' SuperGroup!*', 1, 'md')
      elseif action == "gps" then
        local gp = redis:smembers('gps:') or 0
        local gps = redis:scard('gps:') or 0
        for i=1, #gp do
          sleep(0.5)
          tdcli.forwardMessages(gp[i], chat_id,{[0] = reply_id}, 0)
        end
        tdcli.editMessageText(chat_id, msg.id_, nil, '*Your message was forwarded to '..gps..' Normal Group!*', 1, 'md')
      elseif action == "pv" then
        local gp = redis:smembers('pv:') or 0
        local gps = redis:scard('pv:') or 0
        for i=1, #gp do
          sleep(0.5)
          tdcli.forwardMessages(gp[i], chat_id,{[0] = reply_id}, 0)
        end
        tdcli.editMessageText(chat_id, msg.id_, nil, '*Your message was forwarded to '..gps..' Users*', 1, 'md')
      elseif action == "all" then
        local gp = redis:smembers('pv:') or 0
        local gps = redis:scard('pv:') or 0
        for i=1, #gp do
          sleep(0.5)
          tdcli.forwardMessages(gp[i], chat_id,{[0] = reply_id}, 0)
        end
        local gp = redis:smembers('sgpss:') or 0
        local gps = redis:scard('sgpss:') or 0
        for i=1, #gp do
          sleep(0.5)
          tdcli.forwardMessages(gp[i], chat_id,{[0] = reply_id}, 0)
        end
        local gp = redis:smembers('gps:') or 0
        local gps = redis:scard('gps:') or 0
        for i=1, #gp do
          sleep(0.5)
          tdcli.forwardMessages(gp[i], chat_id,{[0] = reply_id}, 0)
        end
        tdcli.editMessageText(chat_id, msg.id_, nil, '*Your message was forwarded to '..gps..' Users/Group/SuperGroup!*', 1, 'md')
      end
    end
    if input:match("^addtoall$") and msg.reply_to_message_id_ ~= 0 and is_sudo(msg) then
      function add_reply(extra, result, success)
        local gp = redis:smembers('sgpss:') or 0
        local gps = redis:scard('sgpss:') + redis:scard('gps:')
        for i=1, #gp do
          sleep(0.5)
          tdcli.addChatMember(gp[i], result.sender_user_id_, 5)
        end
        local gp = redis:smembers('gps:') or 0
        for i=1, #gp do
          sleep(0.5)
          tdcli.addChatMember(gp[i], result.sender_user_id_, 5)
        end
        tdcli.editMessageText(chat_id, msg.id_, nil, '*Done ...!*\n_This User Added To '..gps..' Sgps/Gps!_', 1, 'md')
        end tdcli.getMessage(chat_id,msg.reply_to_message_id_,add_reply,nil)
      elseif input:match("^addtoall @(.*)") and msg.reply_to_message_id_ == 0 and is_sudo(msg) then
        function add_username(extra, result, success)
          if result.id_ then
            local gp = redis:smembers('sgpss:') or 0
            local gps = redis:scard('sgpss:') + redis:scard('gps:')
            for i=1, #gp do
              sleep(0.5)
              tdcli.addChatMember(gp[i], result.id_, 5)
            end
            local gp = redis:smembers('gps:') or 0
            for i=1, #gp do
              sleep(0.5)
              tdcli.addChatMember(gp[i], result.id_, 5)
            end
            tdcli.editMessageText(chat_id, msg.id_, nil, '*Done ...!*\n_This User Added To '..gps..' Sgps/Gps!_', 1, 'md')
          else
            tdcli.editMessageText(chat_id, msg.id_, nil, '*User Not Found :(*', 1, 'md')
          end
        end
        tdcli.searchPublicChat(input:match("^addtoall @(.*)"),add_username)
      elseif input:match("^addtoall (%d+)") and msg.reply_to_message_id_ == 0 and is_sudo(msg) then
        local gp = redis:smembers('sgpss:') or 0
        local gps = redis:scard('sgpss:') + redis:scard('gps:')
        for i=1, #gp do
          sleep(0.5)
          tdcli.addChatMember(gp[i], input:match("^addtoall (%d+)"), 5)
        end
        local gp = redis:smembers('gps:') or 0
        for i=1, #gp do
          sleep(0.5)
          tdcli.addChatMember(gp[i], input:match("^addtoall (%d+)"), 5)
        end
        tdcli.editMessageText(chat_id, msg.id_, nil, '*Done ...!*\n_This User Added To '..gps..' Sgps/Gps!_', 1, 'md')
      end
      if input:match("^edit (.*)$") and is_sudo(msg) then
        local edittlg = {string.match(txt, "^(edit) (.*)$")}
        tdcli.editMessageText(msg.chat_id_, msg.reply_to_message_id_, nil, edittlg[2], 1, 'html')
      end
      if input:match("^share$") and is_sudo(msg) then
        if reply_id ~= 0 then
          tdcli.sendContact(msg.chat_id_, reply_id, 0, 1, nil, 19804948148, '๓๏ђค๓ค๔', '', bot_id)
          tdcli.deleteMessages(chat_id, {[0] = msg.id_})
        else
          tdcli.sendContact(msg.chat_id_, msg.id_, 0, 1, nil, 19804948148, '๓๏ђค๓ค๔', '', bot_id)
          tdcli.deleteMessages(chat_id, {[0] = msg.id_})
        end
      end
      if input:match("^mute$") and is_sudo(msg) and msg.reply_to_message_id_ then
        function tlg_mute_user(extra, result, success)
          local tlg = 'Self:Muted:'..msg.chat_id_
          if redis:sismember(tlg, result.sender_user_id_) then
            tdcli.editMessageText(chat_id, msg.id_, nil, '> *User* `'..result.sender_user_id_..'` *is Already Muted.*', 1, 'md')
          else
            redis:sadd(tlg, result.sender_user_id_)
            tdcli.editMessageText(chat_id, msg.id_, nil, '> *User* `'..result.sender_user_id_..'` *Muted.*', 1, 'md')
          end
        end
        tdcli.getMessage(msg.chat_id_, msg.reply_to_message_id_,tlg_mute_user)
      end
      if input:match("^mute @(.*)$") and is_sudo(msg) then
        local tlg = {string.match(txt, "^(mute) @(.*)$")}
        function tlg_mute_name(extra, result, success)
          if result.id_ then
            redis:sadd('Self:Muted:'..msg.chat_id_, result.id_)
            texts = '> *User* `'..result.id_..'` *Muted.*'
          else
            texts = '> *User not found!*'
          end
          tdcli.editMessageText(chat_id, msg.id_, nil, texts, 1, 'md')
        end
        tdcli.searchPublicChat(tlg[2],tlg_mute_name)
      end
      if input:match("^mute (%d+)$") and is_sudo(msg) then
        local tlg = {string.match(txt, "^(mute) (%d+)$")}
        redis:sadd('Self:Muted:'..msg.chat_id_, tlg[2])
        tdcli.editMessageText(chat_id, msg.id_, nil, '> *User* `'..tlg[2]..'` *Muted.*', 1, 'md')
      end
      if input:match("^unmute$") and is_sudo(msg) and msg.reply_to_message_id_ then
        function tlg_unmute_user(extra, result, success)
          local tlg = 'Self:Muted:'..msg.chat_id_
          if not redis:sismember(tlg, result.sender_user_id_) then
            tdcli.editMessageText(chat_id, msg.id_, nil, '*User* `'..result.sender_user_id_..'` *is not Muted.*', 1, 'md')
          else
            redis:srem(tlg, result.sender_user_id_)
            tdcli.editMessageText(chat_id, msg.id_, nil, '> *User* `'..result.sender_user_id_..'` *Unmuted.*', 1, 'md')
          end
        end
        tdcli.getMessage(msg.chat_id_, msg.reply_to_message_id_,tlg_unmute_user)
      end
      if input:match("^unmute @(.*)$") and is_sudo(msg) then
        local tlg = {string.match(txt, "^(unmute) @(.*)$")}
        function tlg_unmute_name(extra, result, success)
          if result.id_ then
            redis:srem('Self:Muted:'..msg.chat_id_, result.id_)
            texts = '> *User* `'..result.id_..'` *UnMuted.*'
          else
            texts = '> *User not found!*'
          end
          tdcli.editMessageText(chat_id, msg.id_, nil, 1, text, 1, 'html')
        end
        tdcli.searchPublicChat(tlg[2],tlg_unmute_name)
      end
      if input:match("^unmute (%d+)$") and is_sudo(msg) then
        local tlg = {string.match(txt, "^(unmute) (%d+)$")}
        redis:srem('Self:Muted:'..msg.chat_id_, tlg[2])
        tdcli.editMessageText(chat_id, msg.id_, nil, '> *User* `'..tlg[2]..'` *UnMuted.*', 1, 'md')
      end
      if input:match("^flood (.*)$") and is_sudo(msg) then
        for i=1, 50 do
          tdcli.sendText(chat_id, reply_id, 0, 1, nil, input:match("^flood (.*)$"), 1, 'md')
        end
      end
      if input:match('^[Ss]erver info') and is_sudo(msg) then
        local uptime = io.popen("uptime"):read("*all")
        local ram = io.popen("free -m"):read("*all")
        local cpu = io.popen("lscpu"):read("*all")
        tdcli.editMessageText(chat_id, msg.id_, nil, '*> Self Bot Server Info :*\n----------------------\n> Uptime :\n *'..uptime..'*\n----------------------\n> Ram :\n *'..ram..'*\n----------------------\n> Cpu :\n *'..cpu..'*', 1,'md')
      end
      if input:match("^(reload)$") and is_sudo(msg) then
        loadfile("bot.lua")()
        io.popen("rm -rf ~/root/.telegram-cli/data/animation/*")
        io.popen("rm -rf ~/root/.telegram-cli/data/audio/*")
        io.popen("rm -rf ~/root/.telegram-cli/data/document/*")
        io.popen("rm -rf ~/root/.telegram-cli/data/photo/*")
        io.popen("rm -rf ~/root/.telegram-cli/data/sticker/*")
        io.popen("rm -rf ~/root/.telegram-cli/data/temp/*")
        io.popen("rm -rf ~/root/.telegram-cli/data/video/*")
        io.popen("rm -rf ~/root/.telegram-cli/data/voice/*")
        io.popen("rm -rf ~/root/.telegram-cli/data/profile_photo/*")
        tdcli.editMessageText(chat_id, msg.id_, nil, 'D', 1, 'html')
        sleep(0.7)
        tdcli.editMessageText(chat_id, msg.id_, nil, 'Da', 1, 'html')
        sleep(0.7)
        tdcli.editMessageText(chat_id, msg.id_, nil, 'Dae', 1, 'html')
        sleep(0.7)
        tdcli.editMessageText(chat_id, msg.id_, nil, 'Daei', 1, 'html')
        sleep(0.7)
        tdcli.editMessageText(chat_id, msg.id_, nil, 'DaeiL', 1, 'html')
        sleep(0.7)
        tdcli.editMessageText(chat_id, msg.id_, nil, 'DaeiLa', 1, 'html')
        sleep(0.7)
        tdcli.editMessageText(chat_id, msg.id_, nil, 'DaeiLat', 1, 'html')
        sleep(0.7)
        tdcli.editMessageText(chat_id, msg.id_, nil, 'DaeiLati', 1, 'html')
        sleep(0.7)
        tdcli.editMessageText(chat_id, msg.id_, nil, '@DaeiLati', 1, 'html')
        sleep(0.7)
        tdcli.editMessageText(chat_id, msg.id_, nil, '(@DaeiLati)', 1, 'html')
        sleep(1.3)
        tdcli.editMessageText(chat_id, msg.id_, nil, '@RekhneSecurity\n<b>Self</b> #Bot <b>Reloaded</b>', 1, 'html')
      end
      if input:match("^addmembers$") and is_sudo(msg) then
        function add_all(extra, result)
          local count = result.total_count_
          for i = 0, tonumber(count) - 1 do
            tdcli.addChatMember(chat_id, result.users_[i].id_, 5)
          end
        end
        tdcli.searchContacts(nil, 9999999, add_all, '')
        tdcli.editMessageText(chat_id, msg.id_, nil, '*Adding Members To Group...*', 1, 'md')
      end
      if input:match("^del$") and reply_id and is_sudo(msg) then
        tdcli.deleteMessages(chat_id,{[0] = tonumber(reply_id),msg.id})
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
      if input:match("^settings$") and is_sudo(msg) then
        tdcli.editMessageText(chat_id, msg.id_, nil, '*Self Bot Settings :*\n------------------\n*> Echo :* '..eo..'\n*> Poker :* '..pr..'\n*> Typing :* '..ty..'\n*> Markread :* '..md..'\n*> Autoleave :* '..at..'', 1, 'md')
      end
      if input:match("^help$") and is_sudo(msg) then
        local helptext = [[
        >️ @rekhneSecurity :

        >️ روشن کردن سلف در گروه :
        •• `self on`
        >️ خاموش کردن سلف در گروه :
        •• `self off`

        >️ روشن کردن حالت تایپ در گروه مورد نظر :
        •• `typing on`
        >️ خاموش کردن حالت تایپ در گروه مورد نظر :
        •• `typing off`

        >️ روشن کردن حالت خواندن پیام های ارسال شده :
        •• `markread on`
        >️ خاموش کردن حالت خواندن پیام های ارسال شده :
        •• `markread off`

        >️ روشن کردن حالت پوکر (در این حالت اگر کسی در گروهی 😐 بفرستد سلف در جواب آن 😐 میفرستد) :
        •• `poker on`
        >️ خاموش کردن حالت پوکر :
        •• `poker off`
        >️ روشن کردن حالت خروج خودکار :
        •• `autoleave on`
        >️ خاموش کردن حالت خروج خودکار :
        •• `autoleave off`

        >️ پاک کردن تعداد پیام های مورد نظر در سوپر گروه ها :
        •• `del` [1-100]

        >️ پاک کردن پیام مورد نظر در گروه :
        •• `del` [reply]

        >️ دعوت دوستان مد نظر :
        •• `sos`

        >️ ادد کردن تمامی مخاطبین به گروه :
        •• `addmembers`

        >️ فوروارد کردن پیام مد نظر :
        •• `fwd` [all | sgps | gps | pv]

        >️ ادد کردن شخص مد نظر به تمامی گروها :
        •• `addtoall` [username | reply | id]

        >️ پاک کردن تمامی پیام های شخص مورد نظر در گروه :
        •• `delall` [username | reply | id]

        >️ اخراج فرد مورد نظر از گروه :
        •• `kick` [username | reply | id]

        >️ دعوت فرد مورد نظر به گروه :
        •• `inv` [username | reply | id]

        >️ دریافت آیدی عددی شخص مورد نظر :
        •• `id` [username | reply]

        >️ دریافت آیدی عددی خودتان :
        •• `myid`

        >️ دستوری برای لفت دادن از گروه :
        •• `left`

        >️ ساکت کردن شخص مورد نظر در گروه :
        •• `mute` [username | reply | id]
        >️ پاک کردن شخص مورد نظر از حالت سكوت :
        •• `unmute` [username | reply | id]

        >️ قفل چت در گروه :
        •• `mute all` [sec]
        >️ بازکردن قفل چت در گروه :
        •• `unmute all`

        >️ افزودن شخص به لیست بدخواه (در این حالت سلف شما شخص مورد نظر را در هر گروهی یا حتی پیوی شما تشخیص دهد به شخص مورد نظر فحش میدهد) :
        •• `setenemy` [username | reply | id]
        >️ پاک کردن شخص مورد نظر از لیست بدخواه :
        •• `delenemy` [username | reply | id]
        >️ لیست افراد بدخواه :
        •• `enemylist`
        >️ پاکسازی لیست بدخواه :
        •• `clean enemylist`

        >️ پین کردن پیام مورد نظر در گروه :
        •• `pin`
        >️ آنپین کردن پیام مورد نظر در گروه :
        •• `unpin`

        >️ دستور پایین ک شاید کمی شک برانگیز باشد برای فلود کردن در گروه است ابتدا شما یک نیم فاصله میگذارید سپس متن مورد نظر سپس سلف آن را فلود میکند. توجه مزیت این کار این است ک سلف پیام را فوروارد میکند و شما هرگز ریپورت چت نمیشوید😀
        ‌ ‌[text]

        >️ روشن کرد حالت تکرار (وقتی این حالت روشن شود سلف هرپیامی در گروه ببینید ان را فورواد میکند که نوعی اسپمر به حساب میاید) به دلیل فوروارد مطلب شما هرگز ریپورت چت نمیشوید 😀
        •• `echo on`
        >️ خاموش کردن حالت تکرار :
        •• `echo off`

        >️ نمایش اطلاعات سرور :
        •• `server info`

        >️ ستینگ سلف بات :
        •• `settings`


        >️ پاکسازی اعضای گروه 😈 :
        •• `cm`

        >️ فلود کردن متن :
        •• `flood` [text]

        >️ به اشتراک گذاری شماره شما :
        •• `share`

        >️ تعداد گروه ها و ... شما :
        •• `stats`

        >️ دریافت آیدی گروه :
        •• `gpid`

        >️ بروز کردن سرور - پاکسازی فایل های دانلود شده - بروز کردن فایل bot.lua :
        •• `reload`
        ]]
        tdcli.editMessageText(chat_id, msg.id_, nil, helptext, 1, 'md')
      end
    end
  end
  function tdcli_update_callback(data)
    if (data.ID == "UpdateNewMessage") then
      run(data)
    elseif data.ID == "UpdateMessageEdited" then
      local function edited_cb(arg, data)
        run(data,true)
      end
      tdcli_function ({
        ID = "GetMessage",
        chat_id_ = data.chat_id_,
        message_id_ = data.message_id_
      }, edited_cb, nil)
    elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
      tdcli_function ({
        ID="GetChats",
        offset_order_="9223372036854775807",
        offset_chat_id_=0,
        limit_=20
      }, dl_cb, nil)
    end
  end
