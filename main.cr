require "kemal"
require "pg"
require "db"

# Compose Objects (like Hash) to have a to_json method
require "json/to_json"

# DB pooling for performance
DB_URL = ENV["DATABASE_URL"]? || "postgresql://localhost:5432/profiling"
APPDB = DB.open(DB_URL)

class CONTENT
  UTF8  = "; charset=UTF-8"
  JSON  = "application/json"
  PLAIN = "text/plain"
  HTML  = "text/html" + UTF8
end

private def set_user(user)
  result = APPDB.exec("UPDATE users SET firstName = $1 WHERE id = $2", user[:firstName], user[:id])
  { success: result.rows_affected > 0 }
end

private def users
  data = Array(NamedTuple(id: String, firstName: String)).new

  APPDB.query_each("SELECT id, firstName FROM users") do |rs|
    data.push({id: rs.read(String), firstName: rs.read(String)})
  end

  data
end

before_all do |env|
  env.response.headers["Server"] = "Kemal"
  env.response.headers["Date"] = HTTP.format_time(Time.local)
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
  updated = set_user({id: id, firstName: name})
  env.response.content_type = CONTENT::JSON
  JSON.build do |json|
    json.object do
      updated.each do |key, value|
        json.field key, value
      end
    end
  end
end

Kemal.config do |cfg|
  cfg.serve_static = false
  cfg.logging = false
  cfg.powered_by_header = false
  cfg.server.not_nil!.bind_tcp(cfg.host_binding, cfg.port, reuse_port: true)
end

Kemal.run { |cfg| cfg.server.not_nil!.bind_tcp(cfg.host_binding, cfg.port, reuse_port: true) }
