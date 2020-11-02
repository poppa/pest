import Pest;

int main() {
  describe("This is the second test file!", lambda () {
    test("I will run som tests", lambda () {
      expect("a")->to_be_truthy();
    });

    test("Test 2 in suite 2", lambda () {
      expect(1)->to_be_truthy();
    });
  });
}
