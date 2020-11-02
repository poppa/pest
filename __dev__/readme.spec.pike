
import Pest;

// A test suite file must have a main method
int main() {

  // ... that of the time of writing serves no great purpose
  describe("This is a namespace/block", lambda () {
    test("Expect some stuff to be 'truthy'", lambda () {
      expect(true)->to_be_truthy();
      expect(1)->to_be_truthy();
      expect("a")->to_be_truthy();
    });

    test("Expect some stuff to be 'falsy'", lambda () {
      expect(false)->to_be_falsy();
      expect(0)->to_be_falsy();
      expect(UNDEFINED)->to_be_falsy();
    });

    test("Expect some stuff to be the same (by reference)", lambda () {
      mapping a = ([]);
      mapping b = a;

      expect(a)->to_be(b);
    });

    test("Expect some stuff to be the same (by value)", lambda () {
      mapping a = ([ "index": 1, "value": "one" ]);
      mapping b = ([ "index": 1, "value": "one" ]);

      expect(a)->to_equal(b);
    });

    test("Expect some callback to have been called", lambda () {
      void call_it(function cb) {
        cb();
      };

      function my_callback = fn(lambda() {});
      call_it(my_callback);
      call_it(my_callback);

      expect(my_callback)->to_have_been_called();
      expect(my_callback)->to_have_been_called_n_times(2);
    });
  });
}
