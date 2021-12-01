
public class DropdownListController extends inkLogicController {

  protected edit let m_listContainer: inkCompoundRef;

  private let m_ownerController: wref<IScriptable>;

  private let m_triggerButton: wref<DropdownButtonController>;

  private let m_displayContext: DropdownDisplayContext;

  private let m_activeElement: wref<DropdownElementController>;

  private let m_listOpened: Bool;

  private let m_data: array<ref<DropdownItemData>>;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    this.RegisterToCallback(n"OnRelease", this, n"OnRelease");
    this.Close();
  }

  protected cb func OnRelease(evt: ref<inkPointerEvent>) -> Bool {
    if evt.GetTarget() == this.GetRootWidget() {
      if evt.IsAction(n"click") {
        this.Close();
      };
    };
  }

  protected cb func OnHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    if evt.GetTarget() == this.GetRootWidget() {
      if this.m_listOpened {
        this.Close();
      };
    };
  }

  public final func Setup(owner: wref<inkLogicController>, data: array<ref<DropdownItemData>>, opt triggerButton: ref<DropdownButtonController>) -> Void {
    this.m_ownerController = owner;
    this.m_triggerButton = triggerButton;
    this.SetupData(data);
  }

  public final func Setup(owner: wref<inkGameController>, data: array<ref<DropdownItemData>>, opt triggerButton: ref<DropdownButtonController>) -> Void {
    this.m_ownerController = owner;
    this.m_triggerButton = triggerButton;
    this.SetupData(data);
  }

  public final func Setup(owner: wref<inkLogicController>, displayContext: DropdownDisplayContext, opt triggerButton: ref<DropdownButtonController>) -> Void {
    this.m_ownerController = owner;
    this.m_triggerButton = triggerButton;
    if NotEquals(this.m_displayContext, displayContext) {
      this.SetupData(SortingDropdownData.GetContextDropdownOptions(displayContext));
    };
    this.m_displayContext = displayContext;
  }

  public final func Setup(owner: wref<inkGameController>, displayContext: DropdownDisplayContext, opt triggerButton: ref<DropdownButtonController>) -> Void {
    this.m_ownerController = owner;
    this.m_triggerButton = triggerButton;
    if NotEquals(this.m_displayContext, displayContext) {
      this.SetupData(SortingDropdownData.GetContextDropdownOptions(displayContext));
    };
    this.m_displayContext = displayContext;
  }

  private final func SetupData(data: array<ref<DropdownItemData>>) -> Void {
    let i: Int32;
    let item: ref<DropdownElementController>;
    this.m_data = data;
    inkCompoundRef.RemoveAllChildren(this.m_listContainer);
    i = 0;
    while i < ArraySize(data) {
      item = this.SpawnFromLocal(inkWidgetRef.Get(this.m_listContainer), n"dropdownElement").GetController() as DropdownElementController;
      item.RegisterToCallback(n"OnRelease", this, n"OnDropdownItemClicked");
      item.Setup(data[i]);
      if i == 0 {
        item.SetActive(true);
        this.m_activeElement = item;
      };
      i += 1;
    };
  }

  public final func GetDisplayContext() -> DropdownDisplayContext {
    return this.m_displayContext;
  }

  public final func GetData() -> array<ref<DropdownItemData>> {
    return this.m_data;
  }

  public final func SetTriggerButton(triggerButton: ref<DropdownButtonController>) -> Void {
    this.m_triggerButton = triggerButton;
  }

  public final func Open() -> Void {
    inkWidgetRef.SetVisible(this.m_listContainer, true);
    if IsDefined(this.m_triggerButton) {
      this.m_triggerButton.SetOpened(true);
    };
    this.m_listOpened = true;
  }

  public final func Close() -> Void {
    inkWidgetRef.SetVisible(this.m_listContainer, false);
    if IsDefined(this.m_triggerButton) {
      this.m_triggerButton.SetOpened(false);
    };
    this.m_listOpened = false;
  }

  public final func Toggle() -> Void {
    if this.m_listOpened {
      this.Close();
    } else {
      this.Open();
    };
  }

  public final func IsOpened() -> Bool {
    return this.m_listOpened;
  }

  protected cb func OnDropdownItemClicked(evt: ref<inkPointerEvent>) -> Bool {
    let controller: ref<DropdownElementController>;
    let dropdownEvent: ref<DropdownItemClickedEvent>;
    let targetWidget: wref<inkWidget>;
    if evt.IsAction(n"click") {
      targetWidget = evt.GetCurrentTarget();
      controller = targetWidget.GetController() as DropdownElementController;
      if IsDefined(this.m_activeElement) {
        this.m_activeElement.SetActive(false);
      };
      this.m_activeElement = controller;
      controller.SetActive(true);
      dropdownEvent = new DropdownItemClickedEvent();
      dropdownEvent.owner = this.m_ownerController;
      dropdownEvent.identifier = controller.GetIdentifier();
      dropdownEvent.triggerButton = this.m_triggerButton;
      if IsDefined(this.m_ownerController as inkGameController) {
        this.m_ownerController as inkGameController.QueueEvent(dropdownEvent);
      } else {
        if IsDefined(this.m_ownerController as inkLogicController) {
          this.m_ownerController as inkLogicController.QueueEvent(dropdownEvent);
        };
      };
      this.Close();
    };
  }
}
