public string description;
protected .ProvidesCallbackFunction executor;
protected int ok_count = 0;
protected Error.Generic err;

protected void create(string description, .ProvidesCallbackFunction executor) {
  this::description = description;
  this::executor = executor;
}

public void run() {
  mixed err = catch(executor(lambda () {
    werror("Done callback called\n");
  }));

  if (err) {
    // werror("\tExpectation threw:\n%s\n", err->message());
    // werror("\t%s\n", err->failed_location());
    // err->failed_source();
    this::err = err;
  } else {
    ok_count += 1;
  }
}

public int `successes() {
  return ok_count;
}

public void|Error.Generic `error() {
  return err;
}

public bool `is_success() {
  return !err;
}
