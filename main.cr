require "kemal"
require "pg"

# Compose Objects (like Hash) to have a to_json method
require "json/to_json"

APPDB = DB.open(ENV["DATABASE_URL"])

class CONTENT
  UTF8  = "; charset=UTF-8"
  JSON  = "application/json"
  PLAIN = "text/plain"
  HTML  = "text/html" + UTF8
end

private def set_user(user)
  APPDB.exec("UPDATE world SET firstName = $1 WHERE id = $2", user[:firstName], user[:id])
  world
end

private def users
  data = Array(NamedTuple(id: String, firstName: String)).new

  APPDB.query_each("SELECT id, firstName FROM users") do |rs|
    data.push({id: rs.read(String), message: rs.read(String)})
  end

  data
end

before_all do |env|
  env.response.headers["Server"] = "Kemal"
  env.response.headers["Date"] = HTTP.format_time(Time.now)
end

# Root Endpoint HTML
get "/users" do |env|
  env.response.content_type = CONTENT::HTML
  data = users

  render "views/users.ecr"
end

# Json Endpoint: Database Updates
# {"firstName": "Serdar", "Id": "12312B-A12313"}
post "/webhook" do |env|
    name = env.params.json["firstName"].as(String)
    id = env.params.json["Id"].as(String)
    updated = set_world({id: id, firstName: name})
    env.response.content_type = CONTENT::JSON
    updated.to_json
end


Kemal.config do |cfg|
  cfg.serve_static = false
  cfg.logging = false
  cfg.powered_by_header = false
end

Kemal.run { |cfg| cfg.server.not_nil!.bind_tcp(cfg.host_binding, cfg.port, reuse_port: true) }
