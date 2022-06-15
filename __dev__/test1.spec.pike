import Pest;

class MyClass {
  public function cb;

  void create(function fn) {
    this::cb = fn;
  }

  public void run() {
    cb();
  }
}

int main() {
  test("Root test", lambda () {
    expect(1)->to_equal(1);
  });

  describe("This is the first test!", lambda () {
    test("I will run som tests", lambda () {
      expect(0)->to_be_falsy();
      expect("a")->to_be_truthy();
    });

    test("My function should be called 2 times", lambda () {
      function fun = fn(lambda () {});

      MyClass my_instance = MyClass(fun);
      my_instance->run();
      my_instance->run();

      expect(object_program(my_instance))->to_equal(MyClass);
      expect(fun)->to_have_been_called_n_times(2);
    });

    skip->test("Another test", lambda() {
      expect(([]))->to_equal(([]));
      // expect("a")->to_be_falsy();
    });
  });

  skip->describe("Second description", lambda () {
    test("Some test in scope 2", lambda () {
      expect(1)->to_be_truthy();
    });

    test("Some other test in scope 2", lambda () {
      expect(0)->to_be_falsy();
    });
  });
}
