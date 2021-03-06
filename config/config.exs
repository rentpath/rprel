# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :rprel, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:rprel, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

config :rprel, github_api_endpoint: "https://api.github.com"
config :porcelain, driver: Porcelain.Driver.Basic
config :rprel, system: System
config :rprel, file_upload_timeout: 100_000

import_config "#{Mix.env}.exs"
