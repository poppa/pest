private function(void:.Runner) runner;

protected void create(function(void:.Runner) runner) {
  this::runner = runner;
}

public void describe(string desc, function fn) {
  runner()->add_describer(desc, fn, true);
}

public void test(string desc, function fn) {
  runner()->add_test(desc, fn, true);
}
