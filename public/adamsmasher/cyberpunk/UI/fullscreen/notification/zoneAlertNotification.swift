
public class ZoneAlertNotificationViewData extends GenericNotificationViewData {

  public let m_canBeMerged: Bool;

  public let securityZoneData: ESecurityAreaType;

  public func CanMerge(data: ref<GenericNotificationViewData>) -> Bool {
    let userData: ref<ZoneAlertNotificationViewData> = data as ZoneAlertNotificationViewData;
    return this.m_canBeMerged && IsDefined(userData) && Equals(userData.m_canBeMerged, this.m_canBeMerged);
  }

  public func OnRemoveNotification(data: ref<IScriptable>) -> Bool {
    let requestData: ref<ZoneAlertNotificationRemoveRequestData> = data as ZoneAlertNotificationRemoveRequestData;
    return requestData != null && NotEquals(requestData.m_areaType, this.securityZoneData);
  }
}

public class VehicleAlertNotificationViewData extends GenericNotificationViewData {

  public let m_canBeMerged: Bool;

  public func CanMerge(data: ref<GenericNotificationViewData>) -> Bool {
    return this.m_canBeMerged;
  }
}

public class AwacsAlertNotificationViewData extends GenericNotificationViewData {

  public let m_canBeMerged: Bool;

  public func CanMerge(data: ref<GenericNotificationViewData>) -> Bool {
    return this.m_canBeMerged;
  }
}

public class ZoneAlertNotificationQueue extends gameuiGenericNotificationGameController {

  @default(ZoneAlertNotificationQueue, 2.0f)
  private edit let m_duration: Float;

  private let m_securityBlackBoardID: ref<CallbackHandle>;

  private let m_combatBlackBoardID: ref<CallbackHandle>;

  private let m_wantedValueBlackboardID: ref<CallbackHandle>;

  private let m_bountyAmountBlackboardID: ref<CallbackHandle>;

  private let m_playerBlackboardID: ref<CallbackHandle>;

  private let m_blackboard: wref<IBlackboard>;

  private let m_bountyPrice: Int32;

  private let m_wantedBlackboard: wref<IBlackboard>;

  private let m_wantedBlackboardDef: ref<UI_WantedBarDef>;

  private let m_playerInCombat: Bool;

  private let m_playerPuppet: wref<GameObject>;

  private let m_currentSecurityZoneType: ESecurityAreaType;

  private let m_vehicleZoneBlackboard: wref<IBlackboard>;

  private let m_vehicleZoneBlackboardDef: ref<LocalPlayerDef>;

  private let m_vehicleZoneBlackboardID: ref<CallbackHandle>;

  @default(ZoneAlertNotificationQueue, 5)
  private const let WANTED_TIER_SIZE: Int32;

  private let m_wantedLevel: Int32;

  private let m_factListenerID: Uint32;

  public func GetShouldSaveState() -> Bool {
    return false;
  }

  public func GetID() -> Int32 {
    return EnumInt(GenericNotificationType.ZoneNotification);
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let ownerObject: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    this.m_factListenerID = GameInstance.GetQuestsSystem(ownerObject.GetGame()).RegisterListener(n"awacs_warning", this, n"OnFact");
    this.m_playerPuppet = playerPuppet;
    this.m_blackboard = this.GetPSMBlackboard(this.m_playerPuppet);
    this.m_securityBlackBoardID = this.m_blackboard.RegisterListenerVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData, this, n"OnSecurityDataChange");
    this.m_combatBlackBoardID = this.m_blackboard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Combat, this, n"OnCombatChange");
    this.m_playerInCombat = Equals(IntEnum(this.m_blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat)), gamePSMCombat.InCombat);
    this.m_wantedBlackboardDef = GetAllBlackboardDefs().UI_WantedBar;
    this.m_wantedBlackboard = this.GetBlackboardSystem().Get(this.m_wantedBlackboardDef);
    this.m_wantedValueBlackboardID = this.m_wantedBlackboard.RegisterListenerInt(this.m_wantedBlackboardDef.CurrentWantedLevel, this, n"OnPlayerBountyChange");
    this.m_bountyAmountBlackboardID = this.m_wantedBlackboard.RegisterListenerInt(this.m_wantedBlackboardDef.CurrentBounty, this, n"OnPlayerBountyAmountChange");
    this.m_vehicleZoneBlackboardDef = GetAllBlackboardDefs().UI_LocalPlayer;
    this.m_vehicleZoneBlackboard = this.GetBlackboardSystem().Get(this.m_vehicleZoneBlackboardDef);
    this.m_vehicleZoneBlackboardID = this.m_vehicleZoneBlackboard.RegisterDelayedListenerInt(this.m_vehicleZoneBlackboardDef.InsideVehicleForbiddenAreasCount, this, n"OnVehicleZone");
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    GameInstance.GetQuestsSystem(this.m_playerPuppet.GetGame()).UnregisterListener(n"awacs_warning", this.m_factListenerID);
    this.m_blackboard.UnregisterListenerVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData, this.m_securityBlackBoardID);
    this.m_blackboard.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Combat, this.m_combatBlackBoardID);
    this.m_wantedBlackboard.UnregisterDelayedListener(this.m_wantedBlackboardDef.CurrentWantedLevel, this.m_wantedValueBlackboardID);
    this.m_wantedBlackboard.UnregisterDelayedListener(this.m_wantedBlackboardDef.CurrentBounty, this.m_bountyAmountBlackboardID);
    this.m_vehicleZoneBlackboard.UnregisterDelayedListener(this.m_vehicleZoneBlackboardDef.InsideVehicleForbiddenAreasCount, this.m_vehicleZoneBlackboardID);
  }

  protected cb func OnCombatChange(value: Int32) -> Bool {
    this.m_playerInCombat = Equals(IntEnum(value), gamePSMCombat.InCombat);
  }

  public final func OnFact(val: Int32) -> Void {
    let notificationData: gameuiGenericNotificationData;
    let userData: ref<AwacsAlertNotificationViewData>;
    if val > 0 {
      notificationData.widgetLibraryItemName = n"AVACS_Notification";
      userData = new AwacsAlertNotificationViewData();
      userData.m_canBeMerged = false;
      notificationData.notificationData = userData;
      this.AddNewNotificationData(notificationData);
    };
  }

  protected cb func OnVehicleZone(arg: Int32) -> Bool {
    let notificationData: gameuiGenericNotificationData;
    let userData: ref<VehicleAlertNotificationViewData>;
    notificationData.time = this.m_duration;
    if arg > 0 {
      notificationData.widgetLibraryItemName = n"Area_VehicleForbidden";
      userData = new VehicleAlertNotificationViewData();
      userData.m_canBeMerged = false;
      notificationData.notificationData = userData;
      this.AddNewNotificationData(notificationData);
    };
  }

  protected cb func OnSecurityDataChange(arg: Variant) -> Bool {
    let notificationData: gameuiGenericNotificationData;
    let removeRequest: ref<ZoneAlertNotificationRemoveRequestData>;
    let userData: ref<ZoneAlertNotificationViewData>;
    let securityZoneData: SecurityAreaData = FromVariant(arg);
    notificationData.time = this.m_duration;
    if (securityZoneData.entered || Equals(securityZoneData.securityAreaType, ESecurityAreaType.DISABLED)) && !this.m_playerInCombat {
      switch securityZoneData.securityAreaType {
        case ESecurityAreaType.DANGEROUS:
          notificationData.widgetLibraryItemName = n"Area_Dangerous";
          userData = new ZoneAlertNotificationViewData();
          userData.m_canBeMerged = false;
          if NotEquals(this.m_currentSecurityZoneType, securityZoneData.securityAreaType) {
            userData.securityZoneData = this.m_currentSecurityZoneType = ESecurityAreaType.DANGEROUS;
            notificationData.notificationData = userData;
            this.AddNewNotificationData(notificationData);
          };
          break;
        case ESecurityAreaType.RESTRICTED:
          break;
        case ESecurityAreaType.SAFE:
          notificationData.widgetLibraryItemName = n"Area_Safe";
          userData = new ZoneAlertNotificationViewData();
          userData.m_canBeMerged = false;
          if NotEquals(this.m_currentSecurityZoneType, securityZoneData.securityAreaType) {
            userData.securityZoneData = this.m_currentSecurityZoneType = ESecurityAreaType.SAFE;
            notificationData.notificationData = userData;
            this.AddNewNotificationData(notificationData);
          };
          break;
        default:
          goto 1142;
      };
      notificationData.widgetLibraryItemName = n"Area_Public";
      userData = new ZoneAlertNotificationViewData();
      userData.m_canBeMerged = false;
      if NotEquals(this.m_currentSecurityZoneType, securityZoneData.securityAreaType) {
        userData.securityZoneData = this.m_currentSecurityZoneType = ESecurityAreaType.DISABLED;
        notificationData.notificationData = userData;
        this.AddNewNotificationData(notificationData);
      };
    };
    removeRequest = new ZoneAlertNotificationRemoveRequestData();
    removeRequest.m_areaType = securityZoneData.securityAreaType;
    this.RemoveNotification(removeRequest);
    this.m_currentSecurityZoneType = securityZoneData.securityAreaType;
  }

  protected cb func OnPlayerBountyChange(wantedLevel: Int32) -> Bool {
    let i: Int32;
    let notificationData: gameuiGenericNotificationData;
    let userData: ref<PreventionBountyViewData>;
    let newWantedLevelReached: Bool = false;
    notificationData.time = 4.70;
    if this.m_wantedLevel < wantedLevel {
      this.m_wantedLevel = wantedLevel;
      newWantedLevelReached = true;
    };
    if this.m_wantedLevel == 1 && newWantedLevelReached {
      notificationData.widgetLibraryItemName = n"NCPD_Bounty1";
      userData = new PreventionBountyViewData();
      userData.m_canBeMerged = true;
      userData.bountyTitle = "Level " + ToString(i) + " Bounty Activated";
      userData.bountyPrice = this.m_bountyPrice;
      notificationData.notificationData = userData;
      this.AddNewNotificationData(notificationData);
    };
  }

  protected cb func OnPlayerBountyAmountChange(arg: Int32) -> Bool {
    this.m_bountyPrice = arg;
  }
}

public class ZoneAlertNotification extends GenericNotificationController {

  private let m_animation: ref<inkAnimProxy>;

  private let m_zone_data: ref<ZoneAlertNotificationViewData>;

  private edit let m_ZoneLabelText: inkTextRef;

  public func SetNotificationData(notificationData: ref<GenericNotificationViewData>) -> Void {
    this.m_zone_data = notificationData as ZoneAlertNotificationViewData;
    switch this.m_zone_data.securityZoneData {
      case ESecurityAreaType.DANGEROUS:
        this.PlayLibraryAnimation(n"anim_dangerous");
        this.PlaySound(n"StealthTrespassingPopup", n"OnOpen");
        break;
      case ESecurityAreaType.RESTRICTED:
        this.PlayLibraryAnimation(n"anim_restricted");
        this.PlaySound(n"StealthTrespassingPopup", n"OnOpen");
        break;
      case ESecurityAreaType.SAFE:
        this.PlayLibraryAnimation(n"anim_safe");
        this.PlaySound(n"StealthTrespassingPopup", n"OnOpen");
        break;
      default:
        this.PlayLibraryAnimation(n"anim_public");
    };
    this.PlaySound(n"StealthTrespassingPopup", n"OnOpen");
  }
}

public class VehicleAlertNotification extends GenericNotificationController {

  private let m_animation: ref<inkAnimProxy>;

  private let m_zone_data: ref<VehicleAlertNotificationViewData>;

  private edit let m_ZoneLabelText: inkTextRef;

  public func SetNotificationData(notificationData: ref<GenericNotificationViewData>) -> Void {
    this.PlayLibraryAnimation(n"anim_vehicleforbidden");
    this.PlaySound(n"StealthTrespassingPopup", n"OnOpen");
  }
}

public class AwacsAlertNotification extends GenericNotificationController {

  private let m_animation: ref<inkAnimProxy>;

  private let m_zone_data: ref<VehicleAlertNotificationViewData>;

  private edit let m_ZoneLabelText: inkTextRef;

  public func SetNotificationData(notificationData: ref<GenericNotificationViewData>) -> Void {
    this.PlayLibraryAnimation(n"AVACS_Notification");
    this.PlaySound(n"StealthTrespassingPopup", n"OnOpen");
  }
}

public class PreventionNotification extends GenericNotificationController {

  private let bounty_data: ref<PreventionBountyViewData>;

  private edit let m_bountyTitleText: inkTextRef;

  private edit let m_bountyAmountText: inkTextRef;

  public func SetNotificationData(notificationData: ref<GenericNotificationViewData>) -> Void {
    this.PlaySound(n"StealthTrespassingPopup", n"OnOpen");
    this.bounty_data = notificationData as PreventionBountyViewData;
    inkTextRef.SetText(this.m_bountyTitleText, this.bounty_data.bountyTitle);
    inkTextRef.SetText(this.m_bountyAmountText, ToString(this.bounty_data.bountyPrice));
  }
}

public static exec func awacstest(gi: GameInstance) -> Void {
  AddFact(gi, n"awacs_warning", 1);
}
