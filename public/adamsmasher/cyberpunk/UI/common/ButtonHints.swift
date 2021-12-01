
public class ButtonHints extends inkLogicController {

  public edit let m_horizontalHolder: inkCompoundRef;

  protected cb func OnInitialize() -> Bool {
    inkCompoundRef.RemoveAllChildren(this.m_horizontalHolder);
  }

  public final func AddButtonHint(icon: EInputKey, label: String) -> Void;

  public final func AddButtonHint(action: CName, label: CName, holdInteraction: Bool) -> Void {
    this.AddButtonHint(action, "[" + GetLocalizedText("LocKey#565") + "] " + GetLocalizedTextByKey(label));
  }

  public final func AddButtonHint(action: CName, label: CName) -> Void {
    this.AddButtonHint(action, GetLocalizedTextByKey(label));
  }

  public final func AddButtonHint(action: CName, label: String) -> Void {
    let newWidget: wref<inkWidget>;
    let buttonHint: wref<ButtonHintListItem> = this.CheckForPreExisting(action);
    if buttonHint != null {
      buttonHint.SetData(action, label);
    } else {
      newWidget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_horizontalHolder), n"ButtonHintListItem");
      buttonHint = newWidget.GetController() as ButtonHintListItem;
      buttonHint.SetData(action, label);
    };
  }

  public final func AddCharacterRoatateButtonHint() -> Void {
    this.SpawnFromLocal(inkWidgetRef.Get(this.m_horizontalHolder), n"ButtonHintRotation");
  }

  public final func RemoveButtonHint(action: CName) -> Void {
    let widgetToDelete: wref<inkWidget> = this.RemoveItem(action);
    inkCompoundRef.RemoveChild(this.m_horizontalHolder, widgetToDelete);
  }

  public final func ClearButtonHints() -> Void {
    inkCompoundRef.RemoveAllChildren(this.m_horizontalHolder);
  }

  public final func RemoveItem(action: CName) -> wref<inkWidget> {
    let ctrl: wref<ButtonHintListItem>;
    let widget: wref<inkWidget>;
    let count: Int32 = inkCompoundRef.GetNumChildren(this.m_horizontalHolder);
    let i: Int32 = 0;
    while i < count {
      widget = inkCompoundRef.GetWidgetByIndex(this.m_horizontalHolder, i);
      ctrl = widget.GetController() as ButtonHintListItem;
      if ctrl.CheckAction(action) {
        return widget;
      };
      i += 1;
    };
    return null;
  }

  public final func Hide() -> Void {
    inkWidgetRef.SetVisible(this.m_horizontalHolder, false);
  }

  public final func Show() -> Void {
    inkWidgetRef.SetVisible(this.m_horizontalHolder, true);
  }

  public final func IsVisible() -> Bool {
    return inkWidgetRef.IsVisible(this.m_horizontalHolder);
  }

  private final func CheckForPreExisting(action: CName) -> wref<ButtonHintListItem> {
    let ctrl: wref<ButtonHintListItem>;
    let widget: wref<inkWidget>;
    let count: Int32 = inkCompoundRef.GetNumChildren(this.m_horizontalHolder);
    let i: Int32 = 0;
    while i < count {
      widget = inkCompoundRef.GetWidgetByIndex(this.m_horizontalHolder, i);
      ctrl = widget.GetController() as ButtonHintListItem;
      if ctrl.CheckAction(action) {
        return ctrl;
      };
      i += 1;
    };
    return null;
  }
}

public class ButtonHintListItem extends inkLogicController {

  private edit let m_inputDisplay: inkWidgetRef;

  private edit let m_label: inkTextRef;

  private let m_buttonHint: wref<inkInputDisplayController>;

  private let m_actionName: CName;

  protected cb func OnInitialize() -> Bool {
    this.m_buttonHint = inkWidgetRef.GetController(this.m_inputDisplay) as inkInputDisplayController;
  }

  public final func CheckAction(action: CName) -> Bool {
    return Equals(this.m_actionName, action);
  }

  public final func SetData(action: CName, label: String) -> Void {
    this.m_actionName = action;
    inkTextRef.SetText(this.m_label, label);
    this.m_buttonHint.SetInputAction(this.m_actionName);
  }

  public final func SetData(icon: EInputKey, label: String) -> Void;
}
