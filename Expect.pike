#define THROW_EXPECT_ERR(E1, E2) throw(.Error.ExpectError(E1, E2))

public mixed expression;

protected void create(mixed expression) {
  this::expression = expression;
}

public void to_equal(mixed expectation) {
  if (!equal(expectation, expression)) {
    THROW_EXPECT_ERR(this, expectation);
  }
}

public void to_be(mixed expectation) {
  if (expression != expectation) {
    THROW_EXPECT_ERR(this, expectation);
  }
}

public void to_be_truthy() {
  if (!expression) {
    THROW_EXPECT_ERR(this, "defined");
  }
}

public void to_be_falsy() {
  if (expression) {
    THROW_EXPECT_ERR(this, "undefined");
  }
}

public void to_have_been_called() {
  if (object_program(expression) != .Fn) {
    error("Expression is not a Pest Fn function\n");
  }

  if (expression->count == 0) {
    THROW_EXPECT_ERR(0, "> 0");
  }
}

public void to_have_been_called_n_times(int n) {
  if (object_program(expression) != .Fn) {
    error("Expression is not a Pest Fn function\n");
  }

  if (expression->count != n) {
    THROW_EXPECT_ERR(expression->count, n);
  }
}
