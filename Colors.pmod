public enum Color {
  Reset = "\u001b[0m",
  Red = "\u001b[31m",
  Green = "\u001b[32m",
  Yellow = "\u001b[33m",
  Blue = "\u001b[34m",
  Magenta = "\u001b[35m",
  Cyan = "\u001b[36m",
  White = "\u001b[37m",
  Black = "\u001b[0m",
  DarkGray = "\u001b[38;5;237m",
  Gray = "\u001b[38;5;240m",
  LightGray = "\u001b[38;5;243m",
}

protected typedef function(sprintf_format, sprintf_args:string) ColorFn;

protected ColorFn make_color_fn(Color clr) {
  return lambda (sprintf_format s, sprintf_args ... rest) {
    string ss = sprintf(s, @rest);
    return sprintf("%s%s%s", clr, ss, Reset);
  };
}

public ColorFn red = make_color_fn(Red);
public ColorFn green = make_color_fn(Green);
public ColorFn yellow = make_color_fn(Yellow);
public ColorFn blue = make_color_fn(Blue);
public ColorFn magenta = make_color_fn(Magenta);
public ColorFn cyan = make_color_fn(Cyan);
public ColorFn white = make_color_fn(White);
public ColorFn black = make_color_fn(Black);
public ColorFn dark_grey = make_color_fn(DarkGray);
public ColorFn dark_gray = dark_grey;
public ColorFn grey = make_color_fn(Gray);
public ColorFn gray = grey;
public ColorFn light_grey = make_color_fn(LightGray);
public ColorFn light_gray = light_grey;
public ColorFn reset = make_color_fn(Reset);

public void dump_256() {
  for (int i; i < 16; i++) {
    for (int j; j < 16; j++) {
      int code = i * 16 + j;
      werror("\u001b[38;5;%dm\\u001b[38;5;%dm\n", code, code);
    }
  }

  werror(Reset);
}
