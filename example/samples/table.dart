import 'package:promptly/promptly.dart';
import 'package:promptly/src/console.dart';

const earlyPresidents = [
  [
    1,
    'April 30, 1789 - March 4, 1797',
    'George Washington',
    'unaffiliated',
  ],
  [
    2,
    'March 4, 1797 - March 4, 1801',
    'John Adams',
    'Federalist',
  ],
  [
    3,
    'March 4, 1801 - March 4, 1809',
    'Thomas Jefferson',
    'Democratic-Republican',
  ],
  [
    4,
    'March 4, 1809 - March 4, 1817',
    'James Madison',
    'Democratic-Republican',
  ],
  [
    5,
    'March 4, 1817 - March 4, 1825',
    'James Monroe',
    'Democratic-Republican',
  ],
];

void main() {
  final y = table(
    columns: [Column(text: 'Number'), Column(text: 'President'), Column(text: 'Party'), Column(text: 'Number')],
    rows: earlyPresidents,
  );
  write(y);

  final x = selectTable(
    'Select a row:',
    headers: ['Number', 'Presidency', 'President', 'Party'],
    rows: earlyPresidents,
  );
  write(x.toString());
}
