public typedef array(object(.Describer)|object(.Test)) RunQueue;

public string file;
public program test_suite_program;
public object test_suite_object;

protected bool is_compiled_ok = false;
protected .Describer current_describer;
protected RunQueue run_queue = ({});

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
    werror("collect_test failed: %s => %O\n", describe_backtrace(err), err);
  }
}

public void add_test(string description, function executor, void|bool skip) {
  .Test t = .Test(description, executor);

  if (skip) {
    t->skip = true;
  }

  if (current_describer) {
    current_describer->add_test(t);
  } else {
    run_queue += ({ t });
  }
}

public void add_describer(
  string description,
  function executor,
  void|bool skip
) {
  .Describer d = .Describer(description, executor);

  if (skip) {
    d->skip = true;
  }

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

public void execute(.GlobArg|void test_glob) {
  foreach (run_queue, object obj) {
    if (is_describer(obj)) {
      foreach (obj->tests, .Test t) {
        if (!test_glob || glob(test_glob, t->description)) {
          t->run();
        }
      }
    } else {
      if (!test_glob || glob(test_glob, obj->description)) {
        obj->run();
      }
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

  array successes = filter(tests, lambda (.Test t) { return t->is_success; });
  array failures = filter(tests, lambda (.Test t) { return !!t->error; });
  array skips = filter(tests, lambda (.Test t) { return t->skipped; });

  return ([
    "successes": successes,
    "failures": failures,
    "skips": skips,
  ]);
}

public bool is_describer(object o) {
  return object_program(o) == .Describer;
}

public bool is_test(object o) {
  return object_program(o) == .Test;
}

public RunQueue `queue() {
  return run_queue;
}

public bool has_run_tests() {
  function filter_fn = lambda(.Test|.Describer t) {
    if (is_test(t)) {
      return !t->skipped;
    } else {
      return t->number_of_tests_run() > 0;
    }
  };

  int n = sizeof(filter(run_queue, filter_fn)) > 0;
  return n > 0;
}

protected string _sprintf() {
  return sprintf("%O(%q)", object_program(this), file);
}
