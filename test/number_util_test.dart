import 'package:Financy/utils/number_util.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test("Evaluate math expression 1", () {
    String input = "7439+690.98-47+329";
    double output = NumberUtil.evaluate(input);
    expect(output, 8411.98);
  });

  test("Evaluate math expression 2", () {
    String input = "7434159-690.98-47+329";
    double output = NumberUtil.evaluate(input);
    expect(output, 7433750.02);
  });

  test("Evaluate math expression (single number)", () {
    String input = "7439";
    double output = NumberUtil.evaluate(input);
    expect(output, 7439);
  });

  test("Numpad: add dot", () {
    String input = "7439.0";
    String output = NumberUtil.getMathInput(input, ".");
    expect(output, "7439.0");
  });

  test("Numpad: add plus sign", () {
    String input = "7439.0";
    String output = NumberUtil.getMathInput(input, "+");
    expect(output, "7439.0+");
  });

  test("Numpad: add plus sign", () {
    String input = "7439.";
    String output = NumberUtil.getMathInput(input, "+");
    expect(output, "7439.");
  });

  test("Numpad: add plus sign", () {
    String input = "7439+";
    String output = NumberUtil.getMathInput(input, "+");
    expect(output, "7439+");
  });

  test("Numpad: add plus sign", () {
    String input = "7439.0+343";
    String output = NumberUtil.getMathInput(input, "+");
    expect(output, "7439.0+343+");
  });
}
