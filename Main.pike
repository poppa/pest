protected class PestArgs {
  inherit Arg.Options;

  Opt file = HasOpt("--file")|HasOpt("-f");
  Opt test = HasOpt("--test")|HasOpt("-t");
  Opt verbose = NoOpt("--verbose")|NoOpt("-v");
}

protected string base_dir;

int main(int argc, array(string) argv) {
  string dir = base_dir || dirname(argv[0]);

  if (!dir) {
    string m = sprintf("%O needs to set `base_dir`\n\n", object_program(this));

    m += "  inherit Pest.Main;\n"
      "  protected string base_dir = __DIR__;\n\n"
      "should do the trick!\n\n";

    error(m);
  }

  PestArgs a = PestArgs(argv);

  .GlobArg file_globs;
  .GlobArg test_globs;

  if (a->file) {
    file_globs = a->file / ",";
  }

  if (a->test) {
    test_globs = a->test / ",";
  }

  .run_test(dir, ([
    "files_glob": file_globs,
    "tests_glob": test_globs,
    "verbose": a->verbose,
  ]));
}
