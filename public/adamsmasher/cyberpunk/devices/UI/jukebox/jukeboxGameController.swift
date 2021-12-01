
public class JukeboxInkGameController extends DeviceInkGameControllerBase {

  @attrib(category, "Widget Refs")
  private edit let m_ActionsPanel: inkHorizontalPanelRef;

  @attrib(category, "Widget Refs")
  private edit let m_PriceText: inkTextRef;

  private let m_playButton: wref<PlayPauseActionWidgetController>;

  private let m_nextButton: wref<NextPreviousActionWidgetController>;

  private let m_previousButton: wref<NextPreviousActionWidgetController>;

  private let m_isPlaying: Bool;

  protected func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.RegisterBlackboardCallbacks(blackboard);
  }

  public func UpdateActionWidgets(widgetsData: array<SActionWidgetPackage>) -> Void {
    let action: ref<ScriptableDeviceAction>;
    let i: Int32;
    let price: Int32;
    let textParams: ref<inkTextParams>;
    let widget: ref<inkWidget>;
    this.HideActionWidgets();
    inkWidgetRef.SetVisible(this.m_ActionsPanel, true);
    i = 0;
    while i < ArraySize(widgetsData) {
      widget = this.GetActionWidget(widgetsData[i]);
      if widget == null {
        this.CreateActionWidgetAsync(inkWidgetRef.Get(this.m_ActionsPanel), widgetsData[i]);
      } else {
        this.InitializeActionWidget(widget, widgetsData[i]);
      };
      if price == 0 {
        action = widgetsData[i].action as ScriptableDeviceAction;
        price = action.GetCost();
      };
      i += 1;
    };
    textParams = new inkTextParams();
    textParams.AddNumber("COST", price);
    textParams.AddLocalizedString("ED", "LocKey#884");
    inkTextRef.SetLocalizedTextScript(this.m_PriceText, "LocKey#45350", textParams);
  }

  protected cb func OnActionWidgetSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let actionData: ref<ScriptableDeviceAction>;
    let spawnData: ref<AsyncSpawnData>;
    let widgetData: SActionWidgetPackage;
    super.OnActionWidgetSpawned(widget, userData);
    spawnData = userData as AsyncSpawnData;
    widgetData = FromVariant(spawnData.m_widgetData);
    actionData = widgetData.action as ScriptableDeviceAction;
    if IsDefined(actionData as TogglePlay) {
      this.m_playButton = widget.GetController() as PlayPauseActionWidgetController;
    } else {
      if IsDefined(actionData as NextStation) {
        this.m_nextButton = widget.GetController() as NextPreviousActionWidgetController;
      } else {
        if IsDefined(actionData as PreviousStation) {
          this.m_previousButton = widget.GetController() as NextPreviousActionWidgetController;
        };
      };
    };
  }

  protected final func Decline() -> Void {
    this.PlayLibraryAnimation(n"no_money_root");
    this.m_playButton.Decline();
    this.m_nextButton.Decline();
    this.m_previousButton.Decline();
  }

  protected func ExecuteDeviceActions(controller: ref<DeviceActionWidgetControllerBase>) -> Void {
    let action: ref<BaseScriptableAction>;
    let actions: array<wref<DeviceAction>>;
    let decline: Bool;
    let executor: wref<GameObject>;
    let i: Int32;
    let playAction: ref<TogglePlay>;
    if controller != null {
      if controller.CanExecuteAction() {
        actions = controller.GetActions();
      };
    };
    i = 0;
    while i < ArraySize(actions) {
      executor = GetPlayer(this.GetOwner().GetGame());
      this.ExecuteAction(actions[i], executor);
      controller.FinalizeActionExecution(executor, actions[i]);
      action = actions[i] as BaseScriptableAction;
      playAction = actions[i] as TogglePlay;
      if !action.CanPayCost(executor) {
        decline = true;
      } else {
        if IsDefined(playAction) {
          this.m_isPlaying = FromVariant(playAction.prop.first);
          if this.m_isPlaying {
            this.m_nextButton.Reset();
            this.m_previousButton.Reset();
          } else {
            this.m_nextButton.Deactivate();
            this.m_previousButton.Deactivate();
          };
        };
      };
      i += 1;
    };
    if decline {
      this.Decline();
    };
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  protected func Refresh(state: EDeviceStatus) -> Void {
    this.Refresh(state);
    this.HideActionWidgets();
    this.RequestActionWidgetsUpdate();
  }
}
