#charset utf8
#pike __REAL_VERSION__

constant GenericError = Error.Generic;

import ".";

public typedef function(void:void) VoidFunction;
public typedef function(void:object(GenericError)|void) DoneFunction;
public typedef function(DoneFunction|void:void) ProvidesCallbackFunction;

private array(object(Runner)) runners = ({});
private Runner current_runner;

// NOTE! The mutex stuff in this file serves no purpose atm, since everything
// is run synchronously right now.
private Thread.Mutex runners_mux = Thread.Mutex();

#define ASSERT_RUNNER()                                           \
  do {                                                            \
    if (!current_runner) {                                        \
      error(                                                      \
        "%O() can not be run by itself!\n",                       \
        function_name(this_function)                              \
      );                                                          \
    }                                                             \
  } while (0)

public void describe(string description, VoidFunction tests_executor) {
  if (runners_mux->current_locking_key()) {
    error("A describe block can not be nested\n");
  }

  ASSERT_RUNNER();

  Thread.MutexKey lock = runners_mux->lock();
  current_runner->add_describer(description, tests_executor);
}

public void test(string description, ProvidesCallbackFunction test_runner) {
  bool local_lock = false;
  Thread.MutexKey lock = runners_mux->current_locking_key();

  ASSERT_RUNNER();

  if (!lock) {
    lock = runners_mux->lock();
    local_lock = true;
  }

  current_runner->add_test(description, test_runner);

  if (local_lock) {
    destruct(lock);
  }
}

public Expect expect(mixed expression) {
  ASSERT_RUNNER();
  return Expect(expression);
}

public Fn fn(function callback) {
  return Fn(callback);
}

public void run_test(string root_dir, string|void files_glob) {
  if (!files_glob) {
    files_glob = "*.spec.pike";
  }

  object(Filesystem.Traversion) t = Filesystem.Traversion(root_dir);
  array(string) files = ({});

  foreach (t; string dir; string file) {
    if (glob(files_glob, file)) {
      files += ({ combine_path(dir, file) });
    }
  }

  array(mapping(string:function)) test_suites = ({});

  foreach (files, string file) {
    program test_suite_prog;

    if (mixed err = catch(test_suite_prog = compile_file(file))) {
      werror("Failed compiling %q\n", file);
      // FIXME: Why no BT of the actual compilation error?
      werror("err: %s\n", describe_backtrace(err));
      continue;
    }

    Runner runner = Runner(file, test_suite_prog);
    runners += ({ runner });
  }

  foreach (runners, Runner runner) {
    current_runner = runner;
    runner->collect_tests();
  }

  int n_tests = 0;

  foreach (runners, Runner runner) {
    int nt = runner->get_number_of_tests();

    if (!nt) {
      werror("Test suite file %q has no tests!\n", runner->file);
      runners -= ({ runner });
      continue;
    }

    n_tests += nt;
  }

  int n_suites = sizeof(runners);

  write("Test suites: %s\n", Colors.cyan("%d", n_suites));
  write("Tests: %s\n\n", Colors.cyan("%d", n_tests));

  int start_time = time();

  foreach (runners, Runner runner) {
    write(Colors.light_gray("Running tests in %q\n", runner->file));
    runner->execute();
  }

  write("\n%s\n", Colors.green("Done"));

  float took = time(start_time);

  int total_successes = 0;
  int total_failures = 0;

  foreach (runners, Runner runner) {
    mapping res = runner->report();

    int succeeded = sizeof(res->successes);
    int failed = sizeof(res->failures);

    total_successes += succeeded;
    total_failures += failed;

    if (failed) {
      werror("\n%s\n", "=" * 78);
      werror(
        "%s test%s %s in %s\n",
        Colors.red("%d", failed), failed != 1 ? "s" : "",
        Colors.red("failed"),
        Colors.light_gray("%q", runner->file)
      );

      foreach (res->failures, Test t) {
        werror("\n");
        if (object_program(t->error) == .Error.ExpectError) {
          werror(
            "  %s %s (%s)\n\n",
            Colors.cyan("@test:"),
            t->description,
            Colors.grey(t->error->failed_location())
          );
          t->error->print_error();
        } else {
          [string file, string fnname] = Error.failed_location(t->error);
          werror("  Error in %s %s\n", Colors.cyan("@test:"), t->description);
          werror(
            "  Error occured in %s in function %s\n",
            Colors.light_gray(file),
            Colors.magenta(fnname + "()")
          );
          werror(Colors.red("  > %s\n", t->error[0]));
          werror("  %s\n", Colors.yellow("Backtrace:"));
          Error.print_backtrace(t->error);
        }
      }
    }
  }

  string icon_ok = Colors.green("✔︎");
  string icon_fail = Colors.red("✘");

  foreach (runners, Runner runner) {
    write("\nReport: %s\n", Colors.light_gray(runner->file));

    foreach (runner->queue, object t) {
      if (runner->is_describer(t)) {
        write("  %s\n", t->description);

        foreach (t->tests, Test tt) {
          write(
            "    %s %s\n",
            tt->is_success ? icon_ok : icon_fail,
            Colors.light_gray(tt->description)
          );
        }
      } else {
        write(
          "  %s %s\n",
          t->is_success ? icon_ok : icon_fail,
          Colors.light_gray(t->description)
        );
      }
    }
  }

  write("\n%s\n", "-"*78);
  write(
    "Ran %s test%s in %s test-suite%s\n",
    Colors.cyan(""+n_tests), n_tests != 1 ? "s" : "",
    Colors.cyan(""+n_suites), n_suites != 1 ? "s": ""
  );
  write(
    "%s test%s succeeded, %s test%s failed\n",
    Colors.green(""+total_successes), total_successes != 1 ? "s" : "",
    Colors.red(""+total_failures), total_failures != 1 ? "s" : ""
  );
  write("Ran all tests in %s seconds\n", Colors.cyan(sprintf("%.5f", took)));
  write("%s\n", "-"*78);

  // Colors.dump_256();
}
