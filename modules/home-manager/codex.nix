{
  programs.codex = {
    # Home Manager sets CODEX_HOME when home.preferXdgDirectories is enabled.
    enable = true;

    settings = {
      approval_policy = "on-request";
      approvals_reviewer = "auto_review";
      model = "gpt-5.6-sol";
      model_reasoning_effort = "max";
      service_tier = "fast";
      tui.theme = "ansi";

      # Authenticate once per machine with `codex mcp login linear`.
      mcp_servers.linear.url = "https://mcp.linear.app/mcp";
    };

    context = ''
      ## Linear workflow

      When asked to work on a Linear issue:
      - Read its description, comments, and relevant linked context.
      - Move it to In Progress when implementation starts.
      - Post a completion or handoff comment with changes, verification,
        blockers, and the next action.
      - Include commit or PR links when available.
      - Use In Review when review is pending.
      - Mark Done only when its completion criteria are satisfied.
      - Use the issue team's corresponding statuses when their names differ.
    '';
  };
}
