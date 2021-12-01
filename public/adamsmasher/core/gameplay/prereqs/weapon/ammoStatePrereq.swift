
public class AmmoStateHitTriggeredPrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let checkPassed: Bool;
    let currentAmmo: Uint32;
    let maxAmmo: Uint32;
    let prereq: ref<AmmoStateHitTriggeredPrereq> = this.GetPrereq() as AmmoStateHitTriggeredPrereq;
    let weapon: wref<WeaponObject> = hitEvent.attackData.GetWeapon();
    if IsDefined(weapon) {
      currentAmmo = WeaponObject.GetMagazineAmmoCount(weapon);
    };
    switch prereq.m_valueToListen {
      case EMagazineAmmoState.FirstBullet:
        maxAmmo = GameInstance.GetBlackboardSystem(hitEvent.target.GetGame()).Get(GetAllBlackboardDefs().Weapon).GetUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCapacity);
        checkPassed = currentAmmo >= maxAmmo;
        break;
      case EMagazineAmmoState.LastBullet:
        checkPassed = currentAmmo <= 0u;
        break;
      default:
        return false;
    };
    return checkPassed;
  }
}

public class AmmoStateHitTriggeredPrereq extends HitTriggeredPrereq {

  public let m_valueToListen: EMagazineAmmoState;

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: wref<GameObject> = context as GameObject;
    let castedState: ref<GenericHitPrereqState> = state as GenericHitPrereqState;
    if Equals(this.m_callbackType, gameDamageCallbackType.HitTriggered) {
      castedState.m_listener = new AmmoStateHitTriggeredCallback();
    } else {
      return false;
    };
    castedState.m_listener.RegisterState(castedState);
    if this.m_isSync {
      GameInstance.GetDamageSystem(game).RegisterSyncListener(castedState.m_listener, owner.GetEntityID(), this.m_callbackType, this.m_pipelineStage, DMGPipelineType.All);
    } else {
      GameInstance.GetDamageSystem(game).RegisterListener(castedState.m_listener, owner.GetEntityID(), this.m_callbackType, DMGPipelineType.All);
    };
    return false;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".ammoState", "");
    this.m_valueToListen = IntEnum(Cast(EnumValueFromString("EMagazineAmmoState", str)));
    this.Initialize(recordID);
  }
}

public class AmmoStateHitCallback extends HitCallback {

  public func RegisterState(state: ref<PrereqState>) -> Void {
    this.m_state = state as AmmoStateHitTriggeredPrereqState;
  }

  protected func UpdateState(hitEvent: ref<gameHitEvent>) -> Void {
    let checkPassed: Bool;
    this.m_state.SetHitEvent(hitEvent);
    checkPassed = this.m_state.Evaluate(hitEvent);
    if checkPassed {
      this.m_state.OnChangedRepeated(false);
    };
  }
}

public class AmmoStateHitTriggeredCallback extends AmmoStateHitCallback {

  protected func OnHitTriggered(hitEvent: ref<gameHitEvent>) -> Void {
    this.UpdateState(hitEvent);
  }

  protected func OnHitReceived(hitEvent: ref<gameHitEvent>) -> Void;
}
