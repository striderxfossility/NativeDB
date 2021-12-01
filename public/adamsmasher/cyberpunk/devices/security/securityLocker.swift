
public class SecurityLocker extends InteractiveDevice {

  private let m_inventory: ref<Inventory>;

  private let m_cachedEvent: ref<UseSecurityLocker>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"inventory", n"gameInventory", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ui", n"AdvertisementWidgetComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_inventory = EntityResolveComponentsInterface.GetComponent(ri, n"inventory") as Inventory;
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ui") as IWorldWidgetComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as SecurityLockerController;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  protected func CutPower() -> Void {
    this.CutPower();
    this.TurnOffScreen();
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnDevice();
    this.TurnOnScreen();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.TurnOffScreen();
  }

  private final func TurnOffScreen() -> Void {
    if this.m_uiComponent != null {
      this.m_uiComponent.Toggle(false);
    };
  }

  private final func TurnOnScreen() -> Void {
    if this.m_uiComponent != null {
      this.m_uiComponent.Toggle(true);
    };
  }

  protected cb func OnUseSecurityLocker(evt: ref<UseSecurityLocker>) -> Bool {
    this.m_cachedEvent = evt;
    if !FromVariant(evt.prop.first) {
      this.DisarmUser(evt);
    } else {
      this.ReturnArms(evt);
    };
  }

  protected cb func OnDisarm(evt: ref<Disarm>) -> Bool {
    if (this.GetDevicePS() as SecurityLockerControllerPS).ShouldDisableCyberware() {
      this.ActivateCyberwere(false);
    };
    if this.GetDevicePS().IsPartOfSystem(ESystems.SecuritySystem) {
      this.GetDevicePS().GetSecuritySystem().AuthorizeUser(evt.requester.GetEntityID(), (this.GetDevicePS() as SecurityLockerControllerPS).GetAuthorizationLevel());
    };
  }

  private final func DisarmUser(evt: ref<UseSecurityLocker>) -> Void {
    let disarm: ref<Disarm>;
    if !IsDefined(evt.GetExecutor()) {
      return;
    };
    disarm = new Disarm();
    disarm.requester = this;
    evt.GetExecutor().QueueEvent(disarm);
    GameObject.PlaySoundEvent(this, (this.GetDevicePS() as SecurityLockerControllerPS).GetStoreSFX());
  }

  private final func ReturnArms(evt: ref<UseSecurityLocker>) -> Void {
    let arm: ref<Arm> = new Arm();
    arm.requester = this;
    evt.GetExecutor().QueueEvent(arm);
    if (this.GetDevicePS() as SecurityLockerControllerPS).ShouldDisableCyberware() {
      this.ActivateCyberwere(true);
    };
    GameObject.PlaySoundEvent(this, (this.GetDevicePS() as SecurityLockerControllerPS).GetReturnSFX());
  }

  private final func TransferItems(items: array<wref<gameItemData>>, from: ref<GameObject>, to: ref<GameObject>) -> Void {
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
    let i: Int32 = 0;
    while i < ArraySize(items) {
      if !IsFinal() {
        LogDevices(this, "ITEM TRANSFER: " + items[i].GetNameAsString() + " transfered from: " + NameToString(from.GetClassName()) + " to: " + NameToString(to.GetClassName()));
      };
      transactionSystem.TransferItem(from, to, items[i].GetID(), items[i].GetQuantity());
      i += 1;
    };
  }

  private final func ActivateCyberwere(activate: Bool) -> Void {
    let noCyberware: TweakDBID = t"GameplayRestriction.SecurityLocker";
    let obj: wref<GameObject> = this.m_cachedEvent.GetExecutor();
    if IsDefined(obj) && TDBID.IsValid(noCyberware) {
      if activate {
        StatusEffectHelper.RemoveStatusEffect(obj, noCyberware);
      } else {
        StatusEffectHelper.ApplyStatusEffect(obj, noCyberware);
      };
      this.GetDevicePS().DisconnectPersonalLink(this.m_cachedEvent);
    };
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.ServicePoint;
  }
}
