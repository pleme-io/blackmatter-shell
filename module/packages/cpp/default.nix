pkgs: with pkgs; [
  cmake
  ninja
  gnumake
  ccache
  cppcheck
  bear        # generates compile_commands.json
  clang-tools # clang-format, clang-tidy, etc.
]
++ lib.optionals stdenv.hostPlatform.isLinux [
  gdb
  valgrind
]
++ lib.optionals stdenv.hostPlatform.isDarwin [
  lldb
]
