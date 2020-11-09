-- 公共方法 {{{
local debug = function(key, value)
    ngx.print(key .. ': ' .. value);
    ngx.exit(200);
end

-- 检测路径是否目录
local function is_dir(sPath)
    -- debug('sPath', sPath);
    if type(sPath) ~= "string" then
         return false
    end

    local response = os.execute( "cd " .. sPath .. " 2>&1");
    if response == 0 then
        return true
    end

    return false
end

-- 检测文件是否存在
local file_exists = function(name)
    local f = io.open(name, "r")
    if f ~= nil then io.close(f) return true else return false end
end
-- }}}

local image_size   = ngx.var.image_size;
local originalFile = ngx.var.original;
-- debug('rewrite_uri', ngx.var.rewrite_uri);

-- check original file
if not file_exists(originalFile) then
    -- 原始文件不存在,缩略图也不存在
    -- debug('originalFile', originalFile);
    ngx.exit(404);
end

-- 创建缩略图
local image_size_conf = {"80x80", "800x600", "40x40", "60x60", "640x640", "200x200", "100x100", "369x369", "220x246", "600x600", "100x150"};
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- debug('originalFile', originalFile);
-- debug('des_file', ngx.var.file);

if file_exists(ngx.var.file) then
    -- debug('has file', ngx.var.file);
    ngx.req.set_uri(ngx.var.rewrite_uri, true);
    --ngx.exec(ngx.var.rewrite_uri)
end

if table.contains(image_size_conf, image_size) then
    -- check image dir
    if not is_dir(ngx.var.image_dir) then
        os.execute("mkdir -p " .. ngx.var.image_dir)
    end

    -- debug('image_dir', ngx.var.image_dir);

    local command = "/Users/rick/local/bin/gm convert " .. originalFile  .. " -thumbnail '" .. image_size .. "^' -background gray -gravity center -extent " .. image_size .. " " .. ngx.var.file;
    --debug('cmd', command);
    local ret = os.execute(command);
    --debug('cmd ret', ret);
end;

-- debug('file exists', ngx.var.file);
if file_exists(ngx.var.file) then
    ngx.req.set_uri(ngx.var.rewrite_uri, true);
    --ngx.exec(ngx.var.uri)
else
    ngx.exit(404)
end