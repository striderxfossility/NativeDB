
public class SecurityGateLockController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class SecurityGateLockControllerPS extends ScriptableDeviceComponentPS {

  public let m_tresspasserList: array<TrespasserEntry>;

  public let m_entranceToken: EntityID;

  public let m_isLeaving: Bool;

  @default(SecurityGateLockControllerPS, true)
  public let m_isLocked: Bool;

  public final const func IsLocked() -> Bool {
    return this.m_isLocked;
  }

  public final func UpdateTrespassersList(evt: ref<TriggerEvent>, isEntering: Bool) -> Void {
    let index: Int32;
    let trespasser: ref<ScriptedPuppet>;
    if NotEquals(evt.componentName, n"enteringArea") && NotEquals(evt.componentName, n"centeredArea") && NotEquals(evt.componentName, n"leavingArea") {
      return;
    };
    trespasser = EntityGameInterface.GetEntity(evt.activator) as ScriptedPuppet;
    if !IsDefined(trespasser) {
      return;
    };
    if !IsDefined(trespasser as PlayerPuppet) {
      return;
    };
    if this.IsTrespasserOnTheList(trespasser, index) {
      this.UpdateTrespasserEntry(index, isEntering, evt.componentName);
    } else {
      this.AddTrespasserEntry(trespasser, evt.componentName);
    };
  }

  private final func IsTrespasserOnTheList(trespasser: ref<ScriptedPuppet>, out index: Int32) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_tresspasserList) {
      if this.m_tresspasserList[i].trespasser == trespasser {
        index = i;
        return true;
      };
      i += 1;
    };
    index = -1;
    return false;
  }

  private final func UpdateTrespasserEntry(index: Int32, isEntering: Bool, areaName: CName) -> Void {
    let t: TrespasserEntry = this.m_tresspasserList[index];
    switch areaName {
      case n"enteringArea":
        this.m_tresspasserList[index].isInsideA = isEntering;
        break;
      case n"leavingArea":
        this.m_tresspasserList[index].isInsideB = isEntering;
        break;
      case n"centeredArea":
        this.m_tresspasserList[index].isInsideScanner = isEntering;
        break;
      default:
        if !IsFinal() {
          LogDevices(this, NameToString(areaName) + "is not supported. Check if Security Gate entity has proper StaticAreaComponents", ELogType.WARNING);
        };
    };
    return;
  }

  private final const func IsLegallyLeaving(const t: TrespasserEntry) -> Bool {
    let stackSize: Int32;
    let entrance: CName = n"enteringArea";
    let center: CName = n"centeredArea";
    let leaving: CName = n"leavingArea";
    if ArraySize(t.areaStack) < 3 {
      return false;
    };
    if NotEquals(t.areaStack[0], entrance) {
      return false;
    };
    if Equals(ArrayLast(t.areaStack), leaving) {
      stackSize = ArraySize(t.areaStack);
      if Equals(t.areaStack[stackSize - 2], center) {
        return true;
      };
      return false;
    };
    return false;
  }

  private final func AddTrespasserEntry(trespasser: ref<ScriptedPuppet>, areaName: CName) -> Void {
    let newEntry: TrespasserEntry;
    newEntry.trespasser = trespasser;
    ArrayPush(this.m_tresspasserList, newEntry);
    this.UpdateTrespasserEntry(ArraySize(this.m_tresspasserList) - 1, true, areaName);
  }

  private final func RemoveTrespasserEntry(index: Int32) -> Void {
    ArrayErase(this.m_tresspasserList, index);
  }

  private final func IsTrespasserOutside(index: Int32) -> Bool {
    if this.m_tresspasserList[index].isInsideA || this.m_tresspasserList[index].isInsideB || this.m_tresspasserList[index].isInsideScanner {
      return false;
    };
    return true;
  }

  private final func OnForceUnlock(evt: ref<SecurityGateForceUnlock>) -> EntityNotificationType {
    if !this.IsPowered() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    if evt.shouldUnlock {
      this.m_entranceToken = evt.entranceAllowedFor;
      this.UnlockGate();
    } else {
      this.LockGate(false);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func UnlockGate() -> Void {
    if !this.m_isLocked {
      return;
    };
    this.m_isLocked = false;
    this.UpdateGatePosition();
  }

  private final func LockGate(expireToken: Bool) -> Void {
    let emptyID: EntityID;
    if expireToken {
      this.m_entranceToken = emptyID;
    };
    if this.m_isLocked {
      return;
    };
    this.m_isLocked = true;
    this.UpdateGatePosition();
  }

  private final func UpdateGatePosition() -> Void {
    let updateGatePosition: ref<UpdateGatePosition> = new UpdateGatePosition();
    this.QueueEntityEvent(PersistentID.ExtractEntityID(this.GetID()), updateGatePosition);
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceBackground";
  }
}
