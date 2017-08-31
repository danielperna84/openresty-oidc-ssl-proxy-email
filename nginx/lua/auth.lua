local valid_emails = {}
for s in string.gmatch(os.getenv("OID_VALID_EMAILS"), "([^,]+)") do
    valid_emails[s] = true
end

local features = {}
for f in string.gmatch(os.getenv("OID_FEATURES") or "", "[^,]+") do
    features[f] = true
end

local opts = {
    redirect_uri_path = os.getenv("OID_REDIRECT_PATH"),
    discovery = os.getenv("OID_DISCOVERY"),
    client_id = os.getenv("OID_CLIENT_ID"),
    client_secret = os.getenv("OID_CLIENT_SECRET"),
    scope = "openid email",
    iat_slack = 600,
    features_enabled = features,
}

local function html_escape(s)
    if not s then return "" end
    return (string.gsub(s, "[}{\">/<'&]", {
        ["&"] = "&amp;",
        ["<"] = "&lt;",
        [">"] = "&gt;",
        ['"'] = "&quot;",
        ["'"] = "&#39;",
        ["/"] = "&#47;"
    }))
end

local res, err = require("resty.openidc").authenticate(opts)

if err then
    ngx.status = 500
    ngx.header.content_type = 'text/html';

    ngx.say("There was an error while logging in: " .. html_escape(err) .. "<br><a href='/'>Please try again.</a>")
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

if features.user then
    if ngx.var.user_email then ngx.var.user_email = res.user.upn end
    if ngx.var.user_name  then ngx.var.user_name = string.lower(res.user.given_name .. '.' .. res.user.family_name) end
end

if valid_emails[res.user.email] == nil then
    ngx.log(ngx.ERR, "Failed to login: " .. html_escape(res.user.email))
    ngx.exit(ngx.HTTP_FORBIDDEN)
end
