class PestArgs {
  inherit Arg.Options;

  Opt file = HasOpt("--file")|HasOpt("-f");
  Opt test = HasOpt("--test")|HasOpt("-t");
  Opt verbose = NoOpt("--verbose")|NoOpt("-v");
}

int main(int argc, array(string) argv) {
  PestArgs a = PestArgs(argv);

  .GlobArg file_globs;
  .GlobArg test_globs;

  if (a->file) {
    file_globs = a->file / ",";
  }

  if (a->test) {
    test_globs = a->test / ",";
  }

  .run_test(__DIR__, ([
    "files_glob": file_globs,
    "tests_glob": test_globs,
    "verbose": a->verbose,
  ]));
}
