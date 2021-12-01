
public class OpenStash extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"OpenStash";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#15799", n"LocKey#15799");
  }
}

public class Stash extends InteractiveDevice {

  public let m_inventory: ref<Inventory>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"inventory", n"Inventory", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_inventory = EntityResolveComponentsInterface.GetComponent(ri, n"inventory") as Inventory;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as StashController;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  protected cb func OnOpenStash(evt: ref<OpenStash>) -> Bool {
    let storageBB: ref<IBlackboard>;
    let storageData: ref<StorageUserData>;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
    let player: ref<GameObject> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject();
    if IsDefined(transactionSystem) && IsDefined(player) {
      storageData = new StorageUserData();
      storageData.storageObject = this;
      storageBB = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().StorageBlackboard);
      if IsDefined(storageBB) {
        storageBB.SetVariant(GetAllBlackboardDefs().StorageBlackboard.StorageData, ToVariant(storageData), true);
      };
    };
  }
}

public class StashController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class StashControllerPS extends ScriptableDeviceComponentPS {

  private final const func ActionOpenStash() -> ref<OpenStash> {
    let action: ref<OpenStash> = new OpenStash();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  private final func OnOpenStash(evt: ref<OpenStash>) -> EntityNotificationType {
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    ArrayPush(outActions, this.ActionOpenStash());
    return true;
  }
}
