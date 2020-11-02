public mixed expression;

protected void create(mixed expression) {
  this::expression = expression;
}

public void to_equal(mixed expectation) {
  if (!equal(expectation, expression)) {
    throw(.Error.ExpectError(this, expectation));
  }
}

public void to_be(mixed expectation) {
  if (expression != expectation) {
    throw(.Error.ExpectError(this, expectation));
  }
}

public void to_be_truthy() {
  if (!expression) {
    throw(.Error.ExpectError(this, "defined"));
  }
}

public void to_be_falsy() {
  if (expression) {
    throw(.Error.ExpectError(this, "undefined"));
  }
}

public void to_have_been_called() {
  if (object_program(expression) != .Fn) {
    error("Expression is not a Pest Fn function\n");
  }

  if (expression->count == 0) {
    throw(.Error.ExpectError(0, "> 0"));
  }
}

public void to_have_been_called_n_times(int n) {
  if (object_program(expression) != .Fn) {
    error("Expression is not a Pest Fn function\n");
  }

  if (expression->count != n) {
    throw(.Error.ExpectError(expression->count, n));
  }
}
