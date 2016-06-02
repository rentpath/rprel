ExUnit.configure(exclude: [pending: true, skipped: true])
ExUnit.start()
Application.ensure_all_started(:bypass)
