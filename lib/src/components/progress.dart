import 'dart:async' show StreamSubscription;
import 'dart:io' show ProcessSignal;

import 'package:promptly/src/framework/framework.dart';
import 'package:promptly/src/utils/utils.dart';
import 'package:promptly_ansi/promptly_ansi.dart';

String _startLabel(ProgressData x) {
  int numDigits(int n) => n.toString().length;
  return '${x.filled.toString().padLeft(numDigits(x.length), '')}/${x.length}';
}

String _endLabel(ProgressData x) {
  int numDigits(int n) => n.toString().length;
  return '${x.percentage.toString().padLeft(numDigits(x.length), '')}%';
}

typedef ProgressData = ({int filled, int length});

extension ProgressDataPercentage on ProgressData {
  int get percentage => ((filled / length) * 100).toInt();
}

typedef ProgressFn = String Function(ProgressData progress);

/// A progress bar component.
class Progress extends Component<ProgressState> {
  /// Constructs a [Progress] component with the default theme.
  Progress(
    this.prompt, {
    required this.length,
    this.size = 1.0,
    ProgressFn? startLabel,
    ProgressFn? endLabel,
  })  : theme = Theme.defaultTheme,
        startLabel = startLabel ?? _startLabel,
        endLabel = endLabel ?? _endLabel;

  /// Constructs a [Progress] component with the supplied theme.
  Progress.withTheme(
    this.prompt, {
    required this.theme,
    required this.length,
    this.size = 1.0,
    ProgressFn? startLabel,
    ProgressFn? endLabel,
  })  : startLabel = startLabel ?? _startLabel,
        endLabel = endLabel ?? _endLabel;

  Context? _context;

  final String prompt;

  /// The theme of the component.
  final Theme theme;

  /// The length of the progress bar.
  final int length;

  /// The size multiplier to be used when rendering
  /// the progress bar.
  ///
  /// Will be `1` by default.
  final double size;

  /// The prompt function to be shown on the left side
  /// of the progress bar.
  final ProgressFn startLabel;

  /// The prompt function to be shown on the right side
  /// of the progress bar.
  final ProgressFn endLabel;
  @override
  _ProgressState createState() => _ProgressState();

  @override
  void disposeState(State state) {}

  @override
  State pipeState(State state) {
    if (_context != null) {
      state.setContext(_context!);
    }

    return state;
  }

  /// Sets the context to a new one,
  /// to be used internally by [MultiProgress].
  // ignore: use_setters_to_change_properties
  void setContext(Context c) => _context = c;
}

/// Handles a progress bar's state.
class ProgressState {
  /// Constructs a [ProgressState] with it's all properties.
  ProgressState({
    required this.current,
    required this.clear,
    required this.increase,
    required this.finish,
  });

  /// Current progress.
  int current;

  /// Clears the [current] by setting it to `0`.
  void Function() clear;

  /// Increases the [current] by the given value.
  void Function(int) increase;

  /// To be run to indicate that the progress is done,
  /// and the rendering can be wiped from the terminal.
  void Function() Function() finish;
}

class _ProgressState extends State<Progress> {
  late int current;
  late bool done;
  late StreamSubscription<ProcessSignal> sigint;

  ProgressTheme get theme => component.theme.progressTheme;

  @override
  void init() {
    super.init();
    current = 0;
    done = false;
    sigint = handleSigint();
    context.hideCursor();
  }

  @override
  void dispose() {
    context.wipe();
    context.showCursor();
    super.dispose();
  }

  @override
  void render() {
    final line = StringBuffer();
    final startLabel = component.startLabel((filled: current, length: component.length));
    final endLabel = component.endLabel((filled: current, length: component.length));
    final occupied =
        theme.prefix.strip().length + theme.suffix.strip().length + startLabel.strip().length + endLabel.strip().length;
    final available = (context.windowWidth * component.size).round() - occupied;

    line.write(startLabel);
    line.write(theme.prefix);
    line.write(
      _progress(
        theme,
        available,
        (available / component.length * current).round(),
      ),
    );
    line.write(theme.suffix);
    line.write(endLabel);

    context.writeln(line.toString());
  }

  @override
  ProgressState interact() {
    final state = ProgressState(
      current: current,
      increase: (int n) {
        if (current < component.length) {
          setState(() {
            current += n;
          });
        }
      },
      clear: () {
        setState(() {
          current = 0;
        });
      },
      finish: () {
        setState(() {
          done = true;
          sigint.cancel();
        });

        if (component._context != null) {
          return dispose;
        } else {
          dispose();
          return () {};
        }
      },
    );

    return state;
  }

  String _progress(
    ProgressTheme theme,
    int length,
    int filled,
  ) {
    final f = theme.filledStyle(''.padRight(filled - 1, theme.filled));
    final l = filled == 0
        ? ''
        : filled == length
            ? theme.filledStyle(theme.filled)
            : theme.leadingStyle(theme.leading);
    final e = theme.emptyStyle(''.padRight(length - filled, theme.empty));

    return '$f$l$e';
  }
}
