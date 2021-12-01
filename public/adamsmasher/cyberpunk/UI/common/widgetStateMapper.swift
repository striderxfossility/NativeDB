
public class ListItemStateMapper extends inkLogicController {

  private let m_toggled: Bool;

  private let m_selected: Bool;

  private let m_new: Bool;

  private let m_widget: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_widget = this.GetRootWidget();
    let listController: wref<inkLogicController> = this.m_widget.GetControllerByBaseType(n"inkListItemController");
    listController.RegisterToCallback(n"OnToggledOn", this, n"OnToggledOn");
    listController.RegisterToCallback(n"OnToggledOff", this, n"OnToggledOff");
    listController.RegisterToCallback(n"OnSelected", this, n"OnSelected");
    listController.RegisterToCallback(n"OnDeselected", this, n"OnDeselected");
  }

  protected cb func OnToggledOn(target: wref<ListItemController>) -> Bool {
    this.m_toggled = true;
    this.UpdateState();
  }

  protected cb func OnToggledOff(target: wref<ListItemController>) -> Bool {
    this.m_toggled = false;
    this.UpdateState();
  }

  protected cb func OnSelected(target: wref<ListItemController>) -> Bool {
    this.m_selected = true;
    this.UpdateState();
  }

  protected cb func OnDeselected(target: wref<ListItemController>) -> Bool {
    this.m_selected = false;
    this.UpdateState();
  }

  public final func SetNew(isNew: Bool) -> Void {
    this.m_new = isNew;
    this.UpdateState();
  }

  private func UpdateState() -> Void {
    let newState: String = "";
    if this.m_toggled {
      newState = "Toggled";
    };
    if this.m_selected {
      newState += "Selected";
    };
    if this.m_new {
      newState += "New";
    };
    this.m_widget.SetState(StringToName(newState));
  }
}
