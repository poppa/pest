public string file;
public program test_suite_program;
public object test_suite_object;

protected bool is_compiled_ok = false;
protected .Describer current_describer;
protected array(object(.Describer)|object(.Test)) run_queue = ({});

protected void create(string file, program test_suite_program) {
  this::file = file;
  this::test_suite_program = test_suite_program;

  if (mixed err = catch(test_suite_object = test_suite_program())) {
    werror("Failed instantiating %q\n", file);
    werror("Why no backtrace?: %O\n", err->backtrace());
  } else if (!test_suite_object->main) {
    werror("Missing main() function in %q\n", file);
  } else {
    is_compiled_ok = true;
  }
}

public void collect_tests() {
  if (!is_compiled_ok) {
    return;
  }

  mixed err = catch(test_suite_object->main());

  if (err) {
    werror("collect_test failed: %O\n", err);
  }
}

public void add_test(string description, function executor) {
  if (current_describer) {
    current_describer->add_test(.Test(description, executor));
  } else {
    run_queue += ({ .Test(description, executor) });
  }
}

public void add_describer(string description, function executor) {
  .Describer d = .Describer(description, executor);
  current_describer = d;
  d->run();
  run_queue += ({ d });
  current_describer = 0;
}

public int get_number_of_tests() {
  int n_tests = 0;

   map(run_queue, lambda (object t) {
    if (object_program(t) == .Test) {
      n_tests += 1;
    } else {
      n_tests += sizeof(t->tests);
    }
  });

  return n_tests;
}

public void execute() {
  foreach (run_queue, object obj) {
    if (is_describer(obj)) {
      // write("  %s\n", obj->description);
      foreach (obj->tests, .Test t) {
        // write("    %s\n", t->description);
        // write("    ...");
        t->run();
      }
    } else {
      // write("  %s\n", obj->description);
      // write("  ...");
      obj->run();
    }
  }
}

public mapping report() {
  array(.Test) tests = ({});

  foreach (run_queue, object o) {
    if (is_describer(o)) {
      tests += ({ @o->tests });
    } else {
      tests += ({ o });
    }
  }

  array successes = filter(tests, lambda (.Test t) { return !t->error; });
  array failures = filter(tests, lambda (.Test t) { return !!t->error; });

  return ([
    "successes": successes,
    "failures": failures,
  ]);
}

protected bool is_describer(object o) {
  return object_program(o) == .Describer;
}

protected string _sprintf() {
  return sprintf("%O(%q)", object_program(this), file);
}
