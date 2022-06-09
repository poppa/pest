protected function callback;
protected array(array) callstack = ({});

protected void create(function callback) {
  this::callback = callback;
}

public mixed `()(mixed ... args) {
  callstack += ({ args });
  return callback(@args);
}

public array(array) `calls() {
  return callstack;
}

public int `count() {
  return sizeof(callstack);
}
