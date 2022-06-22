public string description;
public bool skip = false;
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

  if (skip) {
    return;
  }

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
  return !err && !skipped;
}

public bool `skipped() {
  return skip || !was_run;
}
