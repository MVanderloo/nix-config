{
  programs.codex = {
    enable = true;

    settings = {
      approval_policy = "on-request";
      approvals_reviewer = "auto_review";
      model = "gpt-5.6-sol";
      model_reasoning_effort = "max";
      service_tier = "fast";
      tui.theme = "ansi";
    };
  };
}
