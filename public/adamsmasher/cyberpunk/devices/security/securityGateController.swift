
public class SecurityGateController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class SecurityGateControllerPS extends MasterControllerPS {

  private let m_securityGateDetectionProperties: SecurityGateDetectionProperties;

  private let m_securityGateResponseProperties: SecurityGateResponseProperties;

  private let m_securityGateStatus: ESecurityGateStatus;

  private let m_trespassersDataList: array<TrespasserEntry>;

  public final const func GetScannerEntranceType() -> ESecurityGateEntranceType {
    return this.m_securityGateDetectionProperties.scannerEntranceType;
  }

  public final const func GetShouldCheckPlayerOnly() -> Bool {
    return this.m_securityGateDetectionProperties.performCheckOnPlayerOnly;
  }

  protected final func ActionQuickHackAuthorization() -> ref<QuickHackAuthorization> {
    let action: ref<QuickHackAuthorization> = new QuickHackAuthorization();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionQuickHackDistraction();
    currentAction.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(ScriptableDeviceAction.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    if this.IsGlitching() || this.IsDistracting() {
      ScriptableDeviceComponentPS.SetActionsInactiveAll(outActions, "LocKey#7004");
    };
    currentAction = this.ActionQuickHackAuthorization();
    currentAction.SetObjectActionID(t"DeviceAction.OverrideAttitudeClassHack");
    currentAction.SetInactiveWithReason(!this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()), "LocKey#7016");
    ArrayPush(outActions, currentAction);
    this.GetQuickHackActions(outActions, context);
  }

  public final func UpdateTrespassersList(evt: ref<TriggerEvent>, isEntering: Bool) -> Void {
    let index: Int32;
    let trespasser: ref<ScriptedPuppet>;
    if NotEquals(evt.componentName, n"scanningArea") && NotEquals(evt.componentName, n"sideA") && NotEquals(evt.componentName, n"sideB") {
      return;
    };
    trespasser = EntityGameInterface.GetEntity(evt.activator) as ScriptedPuppet;
    if !IsDefined(trespasser) {
      return;
    };
    if !IsDefined(trespasser as PlayerPuppet) && this.GetShouldCheckPlayerOnly() {
      return;
    };
    if this.IsTrespasserOnTheList(trespasser, index) {
      this.UpdateTrespasserEntry(index, isEntering, evt.componentName);
      this.EvaluateIfActionIsRequired(evt.componentName, trespasser.GetEntityID(), isEntering);
    } else {
      this.AddTrespasserEntry(trespasser, evt.componentName);
    };
  }

  private final func IsTrespasserOnTheList(trespasser: ref<ScriptedPuppet>, out index: Int32) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_trespassersDataList) {
      if this.m_trespassersDataList[i].trespasser == trespasser {
        index = i;
        return true;
      };
      i += 1;
    };
    index = -1;
    return false;
  }

  private final func UpdateTrespasserEntry(index: Int32, isEntering: Bool, areaName: CName) -> Void {
    switch areaName {
      case n"sideA":
        this.m_trespassersDataList[index].isInsideA = isEntering;
        break;
      case n"sideB":
        this.m_trespassersDataList[index].isInsideB = isEntering;
        break;
      case n"scanningArea":
        this.m_trespassersDataList[index].isInsideScanner = isEntering;
        break;
      default:
        if !IsFinal() {
          LogDevices(this, NameToString(areaName) + "is not supported. Check if Security Gate entity has proper StaticAreaComponents", ELogType.WARNING);
        };
    };
    return;
  }

  private final func AddTrespasserEntry(trespasser: ref<ScriptedPuppet>, areaName: CName) -> Void {
    let newEntry: TrespasserEntry;
    if this.IsConnectedToSecuritySystem() {
      this.ProtectEntityFromSecuritySystem(true, trespasser.GetEntityID(), true, false);
    };
    newEntry.trespasser = trespasser;
    ArrayPush(this.m_trespassersDataList, newEntry);
    this.UpdateTrespasserEntry(ArraySize(this.m_trespassersDataList) - 1, true, areaName);
  }

  private final func RemoveTrespasserEntry(index: Int32) -> Void {
    if Equals(this.m_securityGateStatus, ESecurityGateStatus.SCANNING) {
      this.TriggerScanResponse(false);
    };
    ArrayErase(this.m_trespassersDataList, index);
  }

  private final func IsTrespasserOutside(index: Int32) -> Bool {
    if this.m_trespassersDataList[index].isInsideA || this.m_trespassersDataList[index].isInsideB || this.m_trespassersDataList[index].isInsideScanner {
      return false;
    };
    return true;
  }

  private final func EvaluateIfActionIsRequired(mostRecentArea: CName, tresspasser: EntityID, isEntering: Bool) -> Void {
    let problem: ESecurityGateScannerIssueType;
    let trespasserIndex: Int32;
    if this.GetUserAuthorizationLevel(tresspasser) > this.m_securityGateResponseProperties.securityLevelAccessGranted {
      if Equals(mostRecentArea, n"scanningArea") && isEntering {
        this.TriggerScanResponse(true);
      };
      return;
    };
    if !this.PerformScannerSmokeCheck(problem) {
      this.ResolveScannerNotReady(problem);
      return;
    };
    if !this.GetTrespasserInScannerArea(trespasserIndex) {
      return;
    };
    if this.m_trespassersDataList[trespasserIndex].isScanned {
      problem = ESecurityGateScannerIssueType.TargetAlreadyScanned;
      this.ResolveScannerNotReady(problem);
      return;
    };
    if Equals(this.m_securityGateDetectionProperties.scannerEntranceType, ESecurityGateEntranceType.AnySide) {
      this.InitiateScan(trespasserIndex);
    } else {
      if this.DetermineIfEnteredFromCorrectSide(trespasserIndex, mostRecentArea) {
        this.InitiateScan(trespasserIndex);
      };
    };
  }

  private final func PerformScannerSmokeCheck(out reason: ESecurityGateScannerIssueType) -> Bool {
    let numberOfPuppetsInTheScanner: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_trespassersDataList) {
      if this.m_trespassersDataList[i].isInsideScanner {
        numberOfPuppetsInTheScanner += 1;
      };
      i += 1;
    };
    if numberOfPuppetsInTheScanner == 1 {
      return true;
    };
    if numberOfPuppetsInTheScanner > 1 {
      reason = ESecurityGateScannerIssueType.Overcrowded;
      return false;
    };
    reason = ESecurityGateScannerIssueType.ScannerEmpty;
    return false;
  }

  private final func ResolveScannerNotReady(reason: ESecurityGateScannerIssueType) -> Void;

  private final func InitiateScan(entryIndex: Int32) -> Void {
    let initiateScanEvent: ref<InitiateScanner>;
    GameInstance.GetActivityLogSystem(this.GetGameInstance()).AddLog("Security Gate: Scanning!");
    initiateScanEvent = new InitiateScanner();
    initiateScanEvent.trespasserEntryIndex = entryIndex;
    this.QueuePSEventWithDelay(this, initiateScanEvent, 1.00);
    this.QueueEntityEvent(this.GetMyEntityID(), initiateScanEvent);
    this.m_securityGateStatus = ESecurityGateStatus.SCANNING;
  }

  public final func OnInitiateScanner(evt: ref<InitiateScanner>) -> EntityNotificationType {
    this.PerformScan(evt.trespasserEntryIndex);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func PerformScan(index: Int32) -> Void {
    let allItems: array<wref<gameItemData>>;
    let hasCyberware: Bool;
    let weapons: array<wref<gameItemData>>;
    if this.GetUserAuthorizationLevel(this.m_trespassersDataList[index].trespasser.GetEntityID()) > this.m_securityGateResponseProperties.securityLevelAccessGranted {
      this.TriggerScanResponse(true);
      return;
    };
    this.RevokeAuthorization(this.m_trespassersDataList[index].trespasser.GetEntityID());
    if NotEquals(this.m_securityGateStatus, ESecurityGateStatus.SCANNING) {
      return;
    };
    GameInstance.GetTransactionSystem(this.GetGameInstance()).GetItemList(this.m_trespassersDataList[index].trespasser, allItems);
    RPGManager.ExtractItemsOfEquipArea(gamedataEquipmentArea.Weapon, allItems, weapons);
    hasCyberware = EquipmentSystem.HasItemInArea(this.m_trespassersDataList[index].trespasser, gamedataEquipmentArea.ArmsCW);
    this.m_trespassersDataList[index].isScanned = true;
    if this.m_securityGateDetectionProperties.performWeaponCheck && ArraySize(weapons) > 0 || this.m_securityGateDetectionProperties.performCyberwareCheck && hasCyberware {
      this.TriggerScanResponse(false);
      return;
    };
    this.TriggerScanResponse(true);
  }

  private final func GetTrespasserInScannerArea(out index: Int32) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_trespassersDataList) {
      if this.m_trespassersDataList[i].isInsideScanner {
        index = i;
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func TriggerScanResponse(isSuccessful: Bool) -> Void {
    let index: Int32;
    let scanResult: ref<SecurityGateResponse>;
    let securityNotificationType: ESecurityNotificationType;
    let trespasser: wref<GameObject>;
    if !this.GetTrespasserInScannerArea(index) {
      return;
    };
    scanResult = new SecurityGateResponse();
    scanResult.scanSuccessful = isSuccessful;
    this.QueueEntityEvent(this.GetMyEntityID(), scanResult);
    trespasser = this.m_trespassersDataList[index].trespasser;
    this.ManageSlaves(trespasser.GetEntityID(), isSuccessful);
    if isSuccessful {
      GameInstance.GetActivityLogSystem(this.GetGameInstance()).AddLog("Security Gate: Scan Successful");
      if this.IsPartOfSystem(ESystems.SecuritySystem) {
        if EnumInt(this.m_securityGateResponseProperties.securityLevelAccessGranted) > EnumInt(ESecurityAccessLevel.ESL_NONE) {
          this.GetSecuritySystem().AuthorizeUser(trespasser.GetEntityID(), this.m_securityGateResponseProperties.securityLevelAccessGranted);
          GameInstance.GetActivityLogSystem(this.GetGameInstance()).AddLog("Security Gate: User Authorized " + EnumValueToString("ESecurityAccessLevel", Cast(EnumInt(this.m_securityGateResponseProperties.securityLevelAccessGranted))));
        };
      };
      this.m_securityGateStatus = ESecurityGateStatus.READY;
    } else {
      GameInstance.GetActivityLogSystem(this.GetGameInstance()).AddLog("Security Gate: Threat detected!");
      this.m_securityGateStatus = ESecurityGateStatus.THREAT_DETECTED;
      switch this.m_securityGateResponseProperties.securityGateResponseType {
        case ESecurityGateResponseType.AUDIOVISUAL_ONLY:
          return;
        case ESecurityGateResponseType.SEC_SYS_REPRIMAND:
          securityNotificationType = ESecurityNotificationType.SECURITY_GATE;
          if !IsFinal() {
            LogDevices(this, "Security Gate Requests REPRIMAND!");
          };
          break;
        case ESecurityGateResponseType.SEC_SYS_COMBAT:
          securityNotificationType = ESecurityNotificationType.COMBAT;
          if !IsFinal() {
            LogDevices(this, "Security Gate Requests COMBAT!");
          };
          break;
        default:
          if !IsFinal() {
            LogDevices(this, "Unsupported securityGateResponseType");
          };
      };
      this.TriggerSecuritySystemNotification(trespasser, trespasser.GetWorldPosition(), securityNotificationType);
    };
  }

  private final func ManageSlaves(trespasser: EntityID, shouldUnlock: Bool) -> Void {
    let action: ref<SecurityGateForceUnlock>;
    let slaves: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(slaves) {
      action = new SecurityGateForceUnlock();
      action.entranceAllowedFor = trespasser;
      action.shouldUnlock = shouldUnlock;
      this.QueuePSEvent(slaves[i], action);
      i += 1;
    };
  }

  private final const func ProtectEntityFromSecuritySystem(shouldProtect: Bool, whoToProtect: EntityID, entered: Bool, hasEntityWithdrawn: Bool) -> Void {
    let suppressSecSysReaction: ref<SuppressSecuritySystemReaction>;
    if Equals(this.m_securityGateResponseProperties.securityGateResponseType, ESecurityGateResponseType.AUDIOVISUAL_ONLY) {
      return;
    };
    suppressSecSysReaction = new SuppressSecuritySystemReaction();
    suppressSecSysReaction.enableProtection = shouldProtect;
    suppressSecSysReaction.protectedEntityID = whoToProtect;
    suppressSecSysReaction.hasEntityWithdrawn = hasEntityWithdrawn;
    if Equals(this.m_securityGateResponseProperties.securityGateResponseType, ESecurityGateResponseType.SEC_SYS_REPRIMAND) {
      suppressSecSysReaction.entered = entered;
    };
    this.QueuePSEvent(this.GetSecuritySystem(), suppressSecSysReaction);
  }

  private final func DetermineIfEnteredFromCorrectSide(trespasserIndex: Int32, areaName: CName) -> Bool {
    let firstSideName: CName;
    if ArraySize(this.m_trespassersDataList[trespasserIndex].areaStack) < 1 {
      if !IsFinal() {
        LogDevices(this, "Weird staticTriggerAreaComponent setup - debug entity", ELogType.WARNING);
      };
      return false;
    };
    firstSideName = this.m_trespassersDataList[trespasserIndex].areaStack[0];
    if NotEquals(areaName, n"scanningArea") {
      return false;
    };
    if Equals(this.m_securityGateDetectionProperties.scannerEntranceType, ESecurityGateEntranceType.OnlySideA) && Equals(firstSideName, n"sideA") {
      return true;
    };
    if Equals(this.m_securityGateDetectionProperties.scannerEntranceType, ESecurityGateEntranceType.OnlySideB) && Equals(firstSideName, n"sideB") {
      return true;
    };
    return false;
  }

  protected final func DetermineIfEntityIsWithdrawing(index: Int32, areaName: CName) -> Bool {
    if Equals(this.m_securityGateDetectionProperties.scannerEntranceType, ESecurityGateEntranceType.AnySide) {
      if Equals(areaName, this.m_trespassersDataList[index].areaStack[0]) {
        return true;
      };
    } else {
      if Equals(this.m_securityGateDetectionProperties.scannerEntranceType, ESecurityGateEntranceType.OnlySideA) {
        if Equals(areaName, n"sideA") {
          return true;
        };
      } else {
        if Equals(areaName, n"sideB") {
          return true;
        };
      };
    };
    return false;
  }

  protected final func RevokeAuthorization(user: EntityID) -> Void {
    let i: Int32;
    let revokeEvent: ref<RevokeAuthorization>;
    let secSys: ref<SecuritySystemControllerPS> = this.GetSecuritySystem();
    if IsDefined(secSys) {
      revokeEvent = new RevokeAuthorization();
      revokeEvent.user = user;
      revokeEvent.level = this.m_securityGateResponseProperties.securityLevelAccessGranted;
      this.QueuePSEvent(secSys, revokeEvent);
    } else {
      i = 0;
      while i < ArraySize(this.m_currentlyAuthorizedUsers) {
        if this.m_currentlyAuthorizedUsers[i].user == user {
          if this.m_currentlyAuthorizedUsers[i].level > ESecurityAccessLevel.ESL_0 {
            this.m_currentlyAuthorizedUsers[i].level = ESecurityAccessLevel.ESL_0;
          };
        };
        i += 1;
      };
    };
  }

  protected func PerformRestart() -> Void {
    let emptyID: EntityID;
    this.ManageSlaves(emptyID, true);
    this.PerformRestart();
  }

  protected func WakeUpDevice() -> Bool {
    let emptyID: EntityID;
    let value: Bool = this.WakeUpDevice();
    this.ManageSlaves(emptyID, false);
    return value;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceBackground";
  }
}
