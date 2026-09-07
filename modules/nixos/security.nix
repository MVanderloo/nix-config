{
  # Server processes routinely handle credentials and private user data. Keep
  # crashes in the journal rather than persisting process memory in coredumps.
  systemd.coredump.enable = false;

  # Do not let a non-wheel account invoke a setuid sudo binary at all.
  security.sudo.execWheelOnly = true;
}
