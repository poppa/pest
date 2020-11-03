import "../module";

public mixed failed_location(Error.Generic err) {
  object frame = err[1][-1];
  string file = frame[0];
  int line = frame[1];
  catch (string fn_name = function_name(frame[2]));

  return ({ sprintf("%s:%d", file, line), fn_name });
}

public void print_backtrace(Error.Generic err) {
  foreach (err[1], object frame) {
    werror("    %O\n", frame);
  }
}

public class ExpectError {
  inherit Error.Generic;

  protected void create(.Expect ex, mixed expected) {
    string message = sprintf(
      "Expected: %O\n"
      "Received: %O\n",
      safe_str(expected),
      safe_str(ex->expression)
    );

    ::create(message, backtrace());
  }

  protected variant void create(string|int|float ex, mixed expected) {
    string message = sprintf(
      "Expected: %O\n"
      "Received: %O\n",
      safe_str(expected),
      safe_str(ex)
    );

    ::create(message, backtrace());
  }

  protected mixed safe_str(mixed s) {
    if (stringp(s)) {
      return replace(s, "\n", "\\n");
    }

    return s;
  }

  public void print_error() {
    array(string) m = message() / "\n";

    werror("    %s\n", .Colors.yellow("%s", m[0]));
    werror("    %s\n\n", .Colors.red("%s", m[1]));
    failed_source();
  }

  public string failed_location() {
    string source = this[1][-3];
    [string file, int line, string fn] = get_error_info();

    return sprintf("%s:%d", file, line);
  }

  array(string) failed_source() {
    [string file, int line, string fn] = get_error_info();

    int start = line - 2;
    int end = line + 2;
    int line_len = sizeof((string)end);

    // This shouldn't happen, but you never know
    if (start < 1) {
      start = 1;
      end = start + 2;
    }

    Stdio.File fp = Stdio.File(file, "r");
    Stdio.LineIterator iter = fp->line_iterator();

    do {
      int idx = iter->index() + 1;

      if (idx >= start) {
        string sln = iter->value();
        string fmt_line = sprintf("%"+line_len+"d: %s", idx, sln);

        if (idx != line) {
          werror("      %s\n", .Colors.gray(fmt_line));
        } else {
          werror("      %s\n", fmt_line);

          int|array(int) pos = get_arg_pos(sln, fn);

          if (!arrayp(pos)) {
            werror("Warn: failed getting position for %O\n", fn);
          } else {
            werror(
              .Colors.yellow(
                "      %s: %s%s\n",
                " " * line_len,
                "-" * pos[0],
                "^" * (pos[1] - pos[0])
              )
            );
          }
        }

        if (idx >= end) {
          break;
        }
      }
    } while (iter->next());

    destruct(iter);
    destruct(fp);
  }

  protected array(int) get_arg_pos(string line, string fn) {
    array(int) re = Regexp.PCRE.Widestring(fn)->exec(line);
    return re;
  }

  protected array(string|int) get_error_info() {
    object frame = this[1][-4];
    string method = function_name(this[1][-3][2]);

    return ({ (string)frame[0], (int)frame[1], method });
  }
}
