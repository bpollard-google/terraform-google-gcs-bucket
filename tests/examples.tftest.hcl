mock_provider "google" {}

run "examples_basic_plans_cleanly" {
  command = plan

  module {
    source = "./examples/basic"
  }
}

run "examples_complete_plans_cleanly" {
  command = plan

  module {
    source = "./examples/complete"
  }
}
