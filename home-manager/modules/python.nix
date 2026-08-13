{ pkgs, config, ... }:
{
  home.packages = with pkgs; [ python3 ];

  xdg.configFile."python/startup.py".text = ''
    # REPL improvements
    import readline
    import rlcompleter

    # common standard library imports
    from datetime import datetime, timedelta
    from math import *
    from pathlib import Path
    from pprint import pprint
    from timeit import timeit
    import itertools as it
    import json
    import os
    import random as r
    import sys

    # common third party imports
    for _mod, _alias in [("pandas", "pd"), ("numpy", "np"), ("polars", "pl")]:
        try:
            _imported = __import__(_mod)
            globals()[_mod] = _imported
            globals()[_alias] = _imported
        except ImportError:
            pass

    readline.parse_and_bind("tab: complete")

    # prompt
    sys.ps1 = "> "
    sys.ps2 = "| "

    sys.displayhook = lambda x: pprint(x) if x is not None else None
  '';

  home.sessionVariables = {
    PYTHONSTARTUP = "${config.xdg.configHome}/python/startup.py";
    PYTHON_HISTORY = "${config.xdg.stateHome}/python/history";
    PYTHONPYCACHEPREFIX = "${config.xdg.cacheHome}/python";
    MPLCONFIGDIR = "${config.xdg.configHome}/matplotlib";
  };
}
