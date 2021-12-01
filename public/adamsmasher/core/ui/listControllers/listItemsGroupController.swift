
public class ListItemsGroupController extends CodexListItemController {

  protected edit let m_menuList: inkCompoundRef;

  protected edit let m_foldArrowRef: inkWidgetRef;

  protected edit let m_foldoutButton: inkWidgetRef;

  protected edit let m_foldoutIndipendently: Bool;

  protected let m_menuListController: wref<ListController>;

  private let m_foldoutButtonController: wref<inkButtonController>;

  protected let m_lastClickedData: wref<IScriptable>;

  protected let m_data: array<ref<IScriptable>>;

  protected let m_isOpen: Bool;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.RegisterToCallback(n"OnAddedToList", this, n"OnAddedToList");
    inkWidgetRef.SetRotation(this.m_foldArrowRef, 0.00);
  }

  protected cb func OnAddedToList(target: wref<ListItemController>) -> Bool {
    this.m_menuListController = inkWidgetRef.GetControllerByType(this.m_menuList, n"inkListController") as ListController;
    this.m_menuListController.RegisterToCallback(n"OnItemActivated", this, n"OnContentClicked");
    if this.m_foldoutIndipendently {
      this.m_foldoutButtonController = inkWidgetRef.GetControllerByType(this.m_foldoutButton, n"inkButtonController") as inkButtonController;
      this.m_foldoutButtonController.RegisterToCallback(n"OnRelease", this, n"OnFoldoutButtonClicked");
    } else {
      this.RegisterToCallback(n"OnToggledOn", this, n"OnToggledOn");
      this.RegisterToCallback(n"OnToggledOff", this, n"OnToggledOff");
    };
  }

  public func SetData(data: array<ref<IScriptable>>) -> Void {
    ArrayClear(this.m_data);
    this.m_data = data;
    if ArraySize(this.m_data) > 0 {
      this.m_lastClickedData = this.m_data[0];
      if this.IsToggled() {
        this.OpenGroup();
      };
    };
  }

  protected cb func OnContentClicked(index: Int32, target: ref<ListItemController>) -> Bool {
    this.ProcessToggledOn(target.GetData());
    this.CallCustomCallback(n"OnContentClicked");
  }

  protected func ProcessToggledOn(data: wref<IScriptable>) -> Void {
    this.m_lastClickedData = data;
  }

  protected cb func OnFoldoutButtonClicked(e: ref<inkPointerEvent>) -> Bool {
    if this.m_foldoutIndipendently {
      if this.m_isOpen {
        this.CloseGroup();
      } else {
        this.OpenGroup();
      };
    };
    e.Handle();
    this.CallCustomCallback(n"OnFoldoutButtonClicked");
  }

  protected cb func OnToggledOn(target: wref<ListItemController>) -> Bool {
    this.OpenGroup();
  }

  protected cb func OnToggledOff(target: wref<ListItemController>) -> Bool {
    this.CloseGroup();
  }

  public func OpenGroup() -> Void {
    this.m_menuListController.Clear();
    this.m_menuListController.PushDataList(this.m_data, true);
    inkWidgetRef.SetVisible(this.m_menuList, true);
    inkWidgetRef.SetRotation(this.m_foldArrowRef, 180.00);
    this.RemoveNew();
  }

  public func CloseGroup() -> Void {
    this.m_menuListController.Clear(true);
    inkWidgetRef.SetVisible(this.m_menuList, false);
    inkWidgetRef.SetRotation(this.m_foldArrowRef, 0.00);
  }

  public final func GetLastClicked() -> wref<IScriptable> {
    return this.m_lastClickedData;
  }

  public func Select(entry: wref<IScriptable>) -> Void {
    let findIndex: Int32 = this.m_menuListController.FindIndex(entry);
    if findIndex >= 0 {
      this.m_menuListController.SetToggledIndex(findIndex);
    };
  }

  public func SelectDefault() -> Void {
    if this.m_menuListController.Size() > 0 {
      this.m_menuListController.SetToggledIndex(0);
    };
  }
}
