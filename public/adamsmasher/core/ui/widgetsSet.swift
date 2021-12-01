
public static func SelectWidgets(widget: ref<inkWidget>, opt selectionRule: inkSelectionRule, opt param: String) -> ref<inkWidgetsSet> {
  let widgetsSet: ref<inkWidgetsSet> = new inkWidgetsSet();
  widgetsSet.Select(widget, selectionRule, param);
  return widgetsSet;
}

public static func SelectWidgets2(widget1: ref<inkWidget>, widget2: ref<inkWidget>, opt selectionRule: inkSelectionRule, opt param: String) -> ref<inkWidgetsSet> {
  let widgetsSet: ref<inkWidgetsSet> = new inkWidgetsSet();
  widgetsSet.Select(widget1, selectionRule, param).Select(widget2, selectionRule, param);
  return widgetsSet;
}

public static func SelectWidgets3(widget1: ref<inkWidget>, widget2: ref<inkWidget>, widget3: ref<inkWidget>, opt selectionRule: inkSelectionRule, opt param: String) -> ref<inkWidgetsSet> {
  let widgetsSet: ref<inkWidgetsSet> = new inkWidgetsSet();
  widgetsSet.Select(widget1, selectionRule, param).Select(widget2, selectionRule, param).Select(widget3, selectionRule, param);
  return widgetsSet;
}

public static func SelectWidgets4(widget1: ref<inkWidget>, widget2: ref<inkWidget>, widget3: ref<inkWidget>, widget4: ref<inkWidget>, opt selectionRule: inkSelectionRule, opt param: String) -> ref<inkWidgetsSet> {
  let widgetsSet: ref<inkWidgetsSet> = new inkWidgetsSet();
  widgetsSet.Select(widget1, selectionRule, param).Select(widget2, selectionRule, param).Select(widget3, selectionRule, param).Select(widget4, selectionRule, param);
  return widgetsSet;
}

public static func SelectWidgets5(widget1: ref<inkWidget>, widget2: ref<inkWidget>, widget3: ref<inkWidget>, widget4: ref<inkWidget>, widget5: ref<inkWidget>, opt selectionRule: inkSelectionRule, opt param: String) -> ref<inkWidgetsSet> {
  let widgetsSet: ref<inkWidgetsSet> = new inkWidgetsSet();
  widgetsSet.Select(widget1, selectionRule, param).Select(widget2, selectionRule, param).Select(widget3, selectionRule, param).Select(widget4, selectionRule, param).Select(widget5, selectionRule, param);
  return widgetsSet;
}
