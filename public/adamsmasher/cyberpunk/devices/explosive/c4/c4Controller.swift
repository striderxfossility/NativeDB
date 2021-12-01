
public class C4Controller extends ExplosiveDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class C4ControllerPS extends ExplosiveDeviceControllerPS {

  @default(C4ControllerPS, C4)
  private persistent let m_itemTweakDBString: CName;

  protected func GameAttached() -> Void;

  private final func ActionActivate() -> ref<ActivateC4> {
    let action: ref<ActivateC4> = new ActivateC4();
    action.clearanceLevel = 1;
    action.SetUp(this);
    action.SetProperties();
    action.CreateInteraction();
    return action;
  }

  private final func ActionDeactivate() -> ref<DeactivateC4> {
    let action: ref<DeactivateC4> = new DeactivateC4();
    action.clearanceLevel = 1;
    action.SetUp(this);
    action.SetProperties();
    action.CreateInteraction();
    return action;
  }

  private final func ActionDetonate() -> ref<DetonateC4> {
    let action: ref<DetonateC4> = new DetonateC4();
    action.clearanceLevel = 1;
    action.SetUp(this);
    action.SetProperties();
    action.CreateInteraction();
    return action;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if this.IsOFF() && GameInstance.GetTransactionSystem(this.GetGameInstance()).HasItem(this.GetPlayerMainObject(), this.GetInventoryItemID()) {
      ArrayPush(actions, this.ActionActivate());
    };
    if this.IsON() {
      ArrayPush(actions, this.ActionDeactivate());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionDetonate();
    currentAction.SetObjectActionID(t"DeviceAction.OverloadClassHack");
    currentAction.SetInactiveWithReason(this.IsON(), "LocKey#7005");
    ArrayPush(outActions, currentAction);
    this.FinalizeGetQuickHackActions(outActions, context);
  }

  protected func PushInactiveInteractionChoice(context: GetActionsContext, out choices: array<InteractionChoice>) -> Void {
    let inactiveChoice: InteractionChoice;
    let baseAction: ref<ActivateC4> = this.ActionActivate();
    inactiveChoice.choiceMetaData.tweakDBName = baseAction.GetTweakDBChoiceRecord();
    inactiveChoice.caption = "DEBUG: Reason Unhandled";
    ChoiceTypeWrapper.SetType(inactiveChoice.choiceMetaData.type, gameinteractionsChoiceType.Inactive);
    if this.IsOFF() {
      inactiveChoice.caption = "[NEED C4]";
      ArrayPush(choices, inactiveChoice);
      return;
    };
  }

  public final func OnActivateC4(evt: ref<ActivateC4>) -> EntityNotificationType {
    let executor: wref<GameObject> = evt.GetExecutor();
    if IsDefined(executor) {
      GameInstance.GetTransactionSystem(this.GetGameInstance()).RemoveItem(executor, this.GetInventoryItemID(), 1);
    };
    this.UseNotifier(evt);
    this.SetDeviceState(EDeviceStatus.ON);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnDeactivateC4(evt: ref<DeactivateC4>) -> EntityNotificationType {
    let executor: wref<GameObject> = evt.GetExecutor();
    if IsDefined(executor) {
      GameInstance.GetTransactionSystem(this.GetGameInstance()).GiveItem(executor, this.GetInventoryItemID(), 1);
    };
    this.UseNotifier(evt);
    this.SetDeviceState(EDeviceStatus.OFF);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnDetonateC4(evt: ref<DetonateC4>) -> EntityNotificationType {
    this.SetDeviceState(EDeviceStatus.DISABLED);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final const func GetItemTweakDBString() -> CName {
    return this.m_itemTweakDBString;
  }

  public final const func GetInventoryItemID() -> ItemID {
    return ItemID.FromTDBID(TDBID.Create("Items." + ToString(this.m_itemTweakDBString)));
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ExplosionDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ExplosionDeviceBackground";
  }
}

public class ActivateC4 extends ActionBool {

  public let itemID: ItemID;

  public final func SetProperties() -> Void {
    this.actionName = n"ActivateC4";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#562", n"LocKey#562");
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    return "PlaceC4";
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if ActivateC4.IsAvailable(device) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsOFF() {
      return true;
    };
    return false;
  }
}

public class DeactivateC4 extends ActionBool {

  public let itemID: ItemID;

  public final func SetProperties() -> Void {
    this.actionName = n"DeactivateC4";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#563", n"LocKey#563");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "DeactivateC4";
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if DeactivateC4.IsAvailable(device) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsON() {
      return true;
    };
    return false;
  }
}

public class DetonateC4 extends ActionBool {

  public let itemID: ItemID;

  public final func SetProperties() -> Void {
    this.actionName = n"DetonateC4";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#564", n"LocKey#564");
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    return "DetonateC4";
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if DetonateC4.IsAvailable(device) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsON() {
      return true;
    };
    return false;
  }
}
