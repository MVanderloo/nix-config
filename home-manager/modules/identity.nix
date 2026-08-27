let
  identity = {
    name = "Michael van der Loo";
    email = "me@mvanderloo.com";
  };
in
{
  programs = {
    git.settings.user = identity;
    jujutsu.settings.user = identity;
  };
}
