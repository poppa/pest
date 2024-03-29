public string description;
public bool skip = false;
protected .VoidFunction tests_executor;

protected array(.Test) _tests = ({});

protected void create(string description, .VoidFunction tests_executor) {
  this::description = description;
  this::tests_executor = tests_executor;
}

public void run() {
  tests_executor();
}

public void add_test(.Test test) {
  if (skip) {
    test->skip = true;
  }

  _tests += ({ test });
}

public array(.Test) `tests() {
  return _tests;
}

public int number_of_tests_run() {
  return sizeof(filter(_tests, lambda (.Test t) { return !t->skipped; }));
}

public bool `skipped() {
  return skip;
}
