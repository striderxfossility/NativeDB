
public class VentilationAreaController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class VentilationAreaControllerPS extends MasterControllerPS {

  private persistent let m_ventilationAreaSetup: VentilationAreaSetup;

  private let isActive: Bool;

  public final func GetActionName() -> CName {
    return this.m_ventilationAreaSetup.m_actionName;
  }

  public final func GetAreaEffect() -> ETrapEffects {
    return this.m_ventilationAreaSetup.m_areaEffect;
  }

  protected func ActionActivateDevice() -> ref<ActivateDevice> {
    let action: ref<ActivateDevice> = this.ActionActivateDevice();
    action.CreateActionWidgetPackage(t"DevicesUIDefinitions.VentilationSystemActionWidget");
    return action;
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(outActions, context);
    if !this.isActive {
      ArrayPush(outActions, this.ActionActivateDevice());
    };
    this.SetActionIllegality(outActions, this.m_illegalActions.regularActions);
    return true;
  }

  protected func OnActivateDevice(evt: ref<ActivateDevice>) -> EntityNotificationType {
    this.OnActivateDevice(evt);
    this.ActivateEffectors();
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func ActivateEffectors() -> Void {
    let action: ref<ToggleEffect>;
    let devices: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let entityID: EntityID = PersistentID.ExtractEntityID(this.GetID());
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetChildren(entityID, devices);
    i = 0;
    while i < ArraySize(devices) {
      action = (devices[i] as ScriptableDeviceComponentPS).GetActionByName(n"ToggleEffect") as ToggleEffect;
      if IsDefined(action) {
        this.GetPersistencySystem().QueuePSDeviceEvent(action);
      };
      i += 1;
    };
  }

  public final const quest func IsAreaActive() -> Bool {
    return this.isActive;
  }

  protected func GetInkWidgetTweakDBID(context: GetActionsContext) -> TweakDBID {
    return t"DevicesUIDefinitions.VentilationSystemDeviceWidget";
  }

  public func GetThumbnailWidget() -> SThumbnailWidgetPackage {
    let widgetData: SThumbnailWidgetPackage = this.GetThumbnailWidget();
    widgetData.widgetTweakDBID = t"DevicesUIDefinitions.VentilationSystemThumnbnailWidget";
    return widgetData;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.VentilationDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.VentilationDeviceBackground";
  }
}
