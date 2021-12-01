
public class UseSecurityLocker extends ActionBool {

  public final func SetProperties(shouldDeposit: Bool) -> Void {
    this.actionName = n"UseSecurityLocker";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, shouldDeposit, n"LocKey#286", n"LocKey#287");
  }

  public func GetTweakDBChoiceRecord() -> String {
    if !FromVariant(this.prop.first) {
      return "DepositWeapons";
    };
    return "RetrieveWeapons";
  }
}

public class SecurityLockerController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class SecurityLockerControllerPS extends ScriptableDeviceComponentPS {

  private let m_securityLockerProperties: SecurityLockerProperties;

  private persistent let m_isStoringPlayerEquipement: Bool;

  public final const func ShouldDisableCyberware() -> Bool {
    return this.m_securityLockerProperties.disableCyberware;
  }

  public final const func GetAuthorizationLevel() -> ESecurityAccessLevel {
    return this.m_securityLockerProperties.securityLevelAccessGranted;
  }

  public final const quest func GetIsEmpty() -> Bool {
    return !this.m_isStoringPlayerEquipement;
  }

  public final const quest func GetIsStoringPlayerEquipement() -> Bool {
    return this.m_isStoringPlayerEquipement;
  }

  public final const func GetStoreSFX() -> CName {
    return this.m_securityLockerProperties.storeWeaponSFX;
  }

  public final const func GetReturnSFX() -> CName {
    return this.m_securityLockerProperties.pickUpWeaponSFX;
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  private final func ActionUseSecurityLocker(executor: ref<GameObject>) -> ref<UseSecurityLocker> {
    let action: ref<UseSecurityLocker> = new UseSecurityLocker();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetProperties(this.m_isStoringPlayerEquipement);
    action.SetExecutor(executor);
    action.SetUp(this);
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  public final func OnUseSecurityLocker(evt: ref<UseSecurityLocker>) -> EntityNotificationType {
    let togglePersonalLink: ref<TogglePersonalLink>;
    if this.ShouldDisableCyberware() {
      togglePersonalLink = this.ActionTogglePersonalLink(evt.GetExecutor());
      togglePersonalLink.SetIllegal(false);
      this.ExecutePSAction(togglePersonalLink, evt.GetInteractionLayer());
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.m_isStoringPlayerEquipement = !this.m_isStoringPlayerEquipement;
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func ResolvePersonalLinkConnection(evt: ref<TogglePersonalLink>, abortOperation: Bool) -> Void {
    this.ResolvePersonalLinkConnection(evt, abortOperation);
    if abortOperation {
      return;
    };
    this.QueueEntityEvent(this.GetMyEntityID(), this.ActionUseSecurityLocker(evt.GetExecutor()));
    this.m_isStoringPlayerEquipement = !this.m_isStoringPlayerEquipement;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if !this.GetActions(actions, context) {
      return false;
    };
    if this.IsON() && Equals(context.requestType, gamedeviceRequestType.Direct) {
      if !this.IsPersonalLinkConnected() && !this.IsPersonalLinkConnecting() {
        ArrayPush(actions, this.ActionUseSecurityLocker(context.processInitiatorObject));
      };
    };
    return true;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceBackground";
  }
}
