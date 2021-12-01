
public native class inkComboBoxController extends inkLogicController {

  public final native func ShowComboBox(targetWidget: wref<inkWidget>) -> Void;

  public final native func HideComboBox() -> Void;

  public final native func GetComboBoxContentWidget() -> wref<inkWidget>;

  public final native func GetPlaceholderWidget() -> wref<inkWidget>;

  public final native func GetComboBox() -> wref<inkWidget>;

  public final func IsComboBoxVisible() -> Bool {
    let comboBox: wref<inkWidget>;
    if IsDefined(comboBox) {
      return NotEquals(comboBox.GetState(), n"Hidden");
    };
    return false;
  }
}
