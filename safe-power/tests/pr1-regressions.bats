#!/usr/bin/env bats

@test "PR1 safety, deadline and notification regressions" {
  run bash "$BATS_TEST_DIRNAME/pr1-regressions.bash"
  [ "$status" -eq 0 ]
}
