class Priority {
  final int priorityVal;
  final String priorityText;

  Priority({this.priorityVal, this.priorityText});

  Map<String, dynamic> toMap() {
    return {
      'priorityVal': priorityVal,
      'priorityText': priorityText,
    };
  }

  static String getPriorityText(int val) {
    return {1: "P1", 2: "P2", 3: "P3", 4: "P4"}[val];
  }
}
