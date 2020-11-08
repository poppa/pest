public string description;
protected .ProvidesCallbackFunction executor;
protected int ok_count = 0;
protected Error.Generic err;
protected bool was_run = false;

protected void create(string description, .ProvidesCallbackFunction executor) {
  this::description = description;
  this::executor = executor;
}

public void run() {
  was_run = true;

  mixed err = catch(executor(lambda () {
    werror("Done callback called\n");
  }));

  if (err) {
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

public bool `skipped() {
  return !was_run;
}
