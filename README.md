# Crystal/Kemal JSON API Server

This is a JSON API server built with [Kemal](https://kemalcr.com/) in [Crystal](https://crystal-lang.org/). It is designed to be compared with an Actix-web server. While Actix-web is known for its safety and speed, Kemal offers faster development and easier maintenance.

Read more : https://studiozenkai.com/post/crystal-high-performance/

## Getting Started

### Prerequisites

Make sure you have Crystal installed on your machine. You can install it using Homebrew:

```sh
brew install crystal
```

### Installation
Clone the repository and navigate into the project directory:

```sh
git clone git@github.com:heri/crystal_pure_api.git
cd crystal_pure_api
```

Install the required dependencies:
```sh
shards install
psql -U postgres
CREATE DATABASE profiling;
\c profiling
CREATE TABLE users (id SERIAL PRIMARY KEY, firstName VARCHAR(255));
```

### Running the Application
Compile the application:
```sh
crystal build main.cr --release
```

Run the application on port 3000:
```sh
KEMAL_PORT=3000 ./main
```

The server should now be running and accessible at http://localhost:3000.

Endpoints
* GET /users: Returns a list of users in HTML format.
* POST /webhook: Updates a user's first name. Expects a JSON payload with firstName and Id.

## Contributing
Feel free to submit issues and pull requests.

## License
This project is licensed under the MIT License.