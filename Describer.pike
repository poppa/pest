public string description;
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
  _tests += ({ test });
}

public array(.Test) `tests() {
  return _tests;
}
