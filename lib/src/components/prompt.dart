import 'package:promptly/src/framework/framework.dart';
import 'package:promptly/src/theme/theme.dart';
import 'package:promptly/src/utils/prompt.dart';
import 'package:promptly/src/validators/validator.dart';

/// An input component.
class Prompt extends StateComponent<String> {
  /// Constructs an [Prompt] component with the default theme.
  Prompt({
    required this.prompt,
    this.validator,
    this.initialText = '',
    this.defaultValue,
    this.value,
  }) : theme = Theme.defaultTheme;

  /// Constructs an [Prompt] component with the supplied theme.
  Prompt.withTheme({
    required this.prompt,
    required this.theme,
    this.validator,
    this.initialText = '',
    this.defaultValue,
    this.value,
  });

  /// The theme for the component.
  final Theme theme;

  /// The prompt to be shown together with the user's input.
  final String prompt;

  /// The initial text to be filled in the input box.
  final String initialText;

  /// The value to be hinted in the [prompt] and will be used
  /// if the user's input is empty.
  final String? defaultValue;

  /// The function that runs with the value after the user has
  /// entered the input. If the function throw a [ValidationError]
  /// instead of returning `true`, the error will be shown and
  /// a new input will be asked.
  final Validator<String>? validator;

  final String? value;

  @override
  _PromptState createState() => _PromptState();
}

class _PromptState extends State<Prompt> {
  String? value;
  String? error;
  int renderCount = 0;
  @override
  void init() {
    super.init();
    value = component.initialText;
  }

  @override
  void dispose() {
    context.erasePreviousLine(renderCount);
    if (value != null) {
      context.write(
        promptSuccess(
          component.prompt,
          theme: component.theme,
          value: value!,
        ),
      );
    }
    super.dispose();
  }

  @override
  void render() {
    if (error != null) {
      context.write(
        promptError(
          error ?? 'An error occurred',
          theme: component.theme,
        ),
      );
      renderCount++;
    }
  }

  @override
  String interact() {
    if (component.value != null) {
      setState(() {
        value = component.value;
      });
      return value!;
    }
    while (true) {
      context.write(
        promptInput(
          theme: component.theme,
          message: component.prompt,
          hint: component.defaultValue,
        ),
      );
      final input = context.readLine(initialText: component.initialText);
      final line = input.isEmpty && component.defaultValue != null ? component.defaultValue! : input;
      final validator = component.validator;

      if (validator != null) {
        try {
          validator.call(line);
        } on ValidationError catch (e) {
          setState(() {
            error = e.message;
          });
          continue;
        }
      }

      setState(() {
        value = line;
      });

      return value!;
    }
  }
}
