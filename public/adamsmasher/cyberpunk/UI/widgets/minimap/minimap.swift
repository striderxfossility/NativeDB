
public native class MinimapContainerController extends MappinsContainerController {

  protected edit let m_rootZoneSafety: wref<inkWidget>;

  protected edit let m_locationTextWidget: inkTextRef;

  protected edit let m_fluffText1: inkTextRef;

  protected edit let m_securityAreaVignetteWidget: inkWidgetRef;

  protected edit let m_securityAreaText: inkTextRef;

  protected edit let m_messageCounter: inkWidgetRef;

  protected edit let m_combatModeHighlight: inkWidgetRef;

  private let m_rootWidget: wref<inkWidget>;

  private let m_zoneVignetteAnimProxy: ref<inkAnimProxy>;

  private let m_inPublicOrRestrictedZone: Bool;

  @default(MinimapContainerController, 0)
  private let m_fluffTextCount: Int32;

  private let m_mapBlackboard: wref<IBlackboard>;

  private let m_mapDefinition: ref<UI_MapDef>;

  private let m_locationDataCallback: ref<CallbackHandle>;

  private let m_securityBlackBoardID: ref<CallbackHandle>;

  private let m_combatAnimation: ref<inkAnimProxy>;

  private let m_playerInCombat: Bool;

  private let m_zoneNeedsUpdate: Bool;

  private let m_lastZoneType: ESecurityAreaType;

  private let m_messageCounterController: wref<inkCompoundWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    inkWidgetRef.SetOpacity(this.m_securityAreaVignetteWidget, 0.00);
    this.m_mapDefinition = GetAllBlackboardDefs().UI_Map;
    this.m_mapBlackboard = this.GetBlackboardSystem().Get(this.m_mapDefinition);
    this.m_locationDataCallback = this.m_mapBlackboard.RegisterListenerString(this.m_mapDefinition.currentLocation, this, n"OnLocationUpdated");
    this.OnLocationUpdated(this.m_mapBlackboard.GetString(this.m_mapDefinition.currentLocation));
    this.m_messageCounterController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_messageCounter), r"base\\gameplay\\gui\\widgets\\phone\\message_counter.inkwidget", n"messages") as inkCompoundWidget;
  }

  protected cb func OnUnitialize() -> Bool {
    this.m_mapBlackboard.UnregisterListenerString(this.m_mapDefinition.currentLocation, this.m_locationDataCallback);
  }

  protected cb func OnPlayerAttach(playerGameObject: ref<GameObject>) -> Bool {
    this.InitializePlayer(playerGameObject);
  }

  protected final func InitializePlayer(playerPuppet: ref<GameObject>) -> Void {
    let psmBlackboard: ref<IBlackboard>;
    let securityData: SecurityAreaData;
    let variantData: Variant;
    let playerSMDef: ref<PlayerStateMachineDef> = GetAllBlackboardDefs().PlayerStateMachine;
    if IsDefined(playerSMDef) {
      psmBlackboard = this.GetPSMBlackboard(playerPuppet);
      if IsDefined(psmBlackboard) {
        this.m_playerInCombat = Equals(IntEnum(psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat)), gamePSMCombat.InCombat);
        this.m_securityBlackBoardID = psmBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData, this, n"OnSecurityDataChange");
        variantData = psmBlackboard.GetVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData);
        if VariantIsValid(variantData) {
          securityData = FromVariant(variantData);
          this.m_lastZoneType = securityData.securityAreaType;
        } else {
          this.m_lastZoneType = ESecurityAreaType.DISABLED;
        };
        this.m_zoneNeedsUpdate = true;
        this.m_inPublicOrRestrictedZone = false;
        this.SecurityZoneUpdate(this.m_lastZoneType);
      };
    };
  }

  protected cb func OnPlayerDetach(playerGameObject: ref<GameObject>) -> Bool {
    let psmBlackboard: ref<IBlackboard> = this.GetPSMBlackboard(playerGameObject);
    if IsDefined(psmBlackboard) {
      if IsDefined(this.m_securityBlackBoardID) {
        psmBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData, this.m_securityBlackBoardID);
      };
    };
  }

  protected cb func OnLocationUpdated(value: String) -> Bool {
    inkTextRef.SetText(this.m_locationTextWidget, StrLen(value) == 0 ? "Story-base-journal-contacts-unknown-Unknown_name" : value);
  }

  protected cb func OnPSMCombatChanged(psmCombatArg: gamePSMCombat) -> Bool {
    let playbackOptions: inkAnimOptions;
    let inCombat: Bool = Equals(psmCombatArg, gamePSMCombat.InCombat);
    if NotEquals(this.m_playerInCombat, inCombat) {
      this.m_playerInCombat = inCombat;
      if this.m_playerInCombat {
        inkWidgetRef.SetVisible(this.m_combatModeHighlight, true);
        if !IsDefined(this.m_combatAnimation) || !this.m_combatAnimation.IsPlaying() {
          playbackOptions.loopInfinite = true;
          playbackOptions.loopType = inkanimLoopType.Cycle;
          this.m_combatAnimation = this.PlayLibraryAnimation(n"CombatMode", playbackOptions);
        };
        inkWidgetRef.SetState(this.m_securityAreaVignetteWidget, n"Combat");
        inkWidgetRef.SetVisible(this.m_securityAreaText, true);
        inkTextRef.SetLocalizationKey(this.m_securityAreaText, n"Story-base-gameplay-gui-widgets-minimap-zones-Combat");
      } else {
        inkWidgetRef.SetVisible(this.m_combatModeHighlight, false);
        if this.m_combatAnimation.IsPlaying() {
          this.m_combatAnimation.Stop();
        };
        if IsDefined(this.m_zoneVignetteAnimProxy) && this.m_zoneVignetteAnimProxy.IsPlaying() {
          this.m_zoneVignetteAnimProxy.Stop();
        };
        this.m_zoneVignetteAnimProxy = this.PlayLibraryAnimation(n"FadeInZoneSafety");
        inkWidgetRef.SetState(this.m_securityAreaVignetteWidget, this.ZoneToState(this.m_lastZoneType));
        if this.m_inPublicOrRestrictedZone {
          inkWidgetRef.SetVisible(this.m_securityAreaText, false);
        } else {
          inkWidgetRef.SetVisible(this.m_securityAreaText, true);
          inkTextRef.SetLocalizationKey(this.m_securityAreaText, this.ZoneToTextKey(this.m_lastZoneType));
        };
      };
    };
  }

  protected cb func OnSecurityDataChange(value: Variant) -> Bool {
    let securityData: SecurityAreaData;
    let zoneType: ESecurityAreaType;
    if VariantIsValid(value) {
      securityData = FromVariant(value);
    };
    zoneType = securityData.securityAreaType;
    if NotEquals(zoneType, this.m_lastZoneType) {
      this.m_lastZoneType = zoneType;
      this.m_zoneNeedsUpdate = true;
    };
    this.SecurityZoneUpdate(zoneType);
  }

  private final func SecurityZoneUpdate(zone: ESecurityAreaType) -> Void {
    if this.m_zoneNeedsUpdate && !this.m_playerInCombat {
      if IsDefined(this.m_zoneVignetteAnimProxy) && this.m_zoneVignetteAnimProxy.IsPlaying() {
        this.m_zoneVignetteAnimProxy.Stop();
      };
      switch zone {
        case ESecurityAreaType.RESTRICTED:
          if !this.m_inPublicOrRestrictedZone {
            this.m_zoneVignetteAnimProxy = this.PlayLibraryAnimation(n"FadeInZoneSafety");
          };
          this.m_inPublicOrRestrictedZone = true;
          break;
        case ESecurityAreaType.DANGEROUS:
          this.m_zoneVignetteAnimProxy = this.PlayLibraryAnimation(n"FadeInZoneDanger");
          this.m_inPublicOrRestrictedZone = false;
          break;
        case ESecurityAreaType.SAFE:
          this.m_zoneVignetteAnimProxy = this.PlayLibraryAnimation(n"FadeInZoneSafety");
          this.m_inPublicOrRestrictedZone = false;
          break;
        default:
          if !this.m_inPublicOrRestrictedZone {
            this.m_zoneVignetteAnimProxy = this.PlayLibraryAnimation(n"FadeInZoneSafety");
          };
      };
      this.m_inPublicOrRestrictedZone = true;
      inkWidgetRef.SetState(this.m_securityAreaVignetteWidget, this.ZoneToState(zone));
      if this.m_inPublicOrRestrictedZone {
        inkWidgetRef.SetVisible(this.m_securityAreaText, false);
      } else {
        inkWidgetRef.SetVisible(this.m_securityAreaText, true);
        inkTextRef.SetLocalizationKey(this.m_securityAreaText, this.ZoneToTextKey(zone));
      };
      this.m_fluffTextCount = this.m_fluffTextCount + 1;
      if this.m_fluffTextCount > 10 {
        this.m_fluffTextCount = 0;
        inkTextRef.SetTextFromParts(this.m_fluffText1, "UI-Cyberpunk-Widgets-FRMWARE_2077V", IntToString(RandRange(10, 99)), "");
      };
    };
    this.m_zoneNeedsUpdate = false;
  }

  protected cb func OnPlayerEnterArea(controller: wref<MinimapSecurityAreaMappinController>) -> Bool;

  protected cb func OnPlayerExitArea(controller: wref<MinimapSecurityAreaMappinController>) -> Bool;

  public func CreateMappinUIProfile(mappin: wref<IMappin>, mappinVariant: gamedataMappinVariant, customData: ref<MappinControllerCustomData>) -> MappinUIProfile {
    let questMappin: wref<QuestMappin>;
    let roleData: ref<GameplayRoleMappinData>;
    let defaultRuntimeProfile: TweakDBID = t"MinimapMappinUIProfile.Default";
    if customData != null && (customData as MinimapQuestAreaInitData) != null {
      return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\minimap\\minimap_quest_area_mappin.inkwidget", t"MappinUISpawnProfile.Always", defaultRuntimeProfile);
    };
    if mappin.IsExactlyA(n"gamemappinsPointOfInterestMappin") {
      return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\minimap\\minimap_poi_mappin.inkwidget", t"MappinUISpawnProfile.ShortRange", defaultRuntimeProfile);
    };
    roleData = mappin.GetScriptData() as GameplayRoleMappinData;
    if roleData != null {
      return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\minimap\\minimap_device_mappin.inkwidget", t"MappinUISpawnProfile.Always", t"MinimapMappinUIProfile.GameplayRole");
    };
    switch mappinVariant {
      case gamedataMappinVariant.FastTravelVariant:
        return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\minimap\\minimap_poi_mappin.inkwidget", t"MappinUISpawnProfile.ShortRange", t"MinimapMappinUIProfile.FastTravel");
      case gamedataMappinVariant.ServicePointDropPointVariant:
        return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\minimap\\minimap_poi_mappin.inkwidget", t"MappinUISpawnProfile.ShortRange", t"MinimapMappinUIProfile.DropPoint");
      case gamedataMappinVariant.Zzz03_MotorcycleVariant:
      case gamedataMappinVariant.VehicleVariant:
        return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\minimap\\minimap_poi_mappin.inkwidget", t"MappinUISpawnProfile.Always", t"MinimapMappinUIProfile.Vehicle");
      case gamedataMappinVariant.CustomPositionVariant:
        return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\minimap\\minimap_poi_mappin.inkwidget", t"MappinUISpawnProfile.Always", defaultRuntimeProfile);
      case gamedataMappinVariant.ExclamationMarkVariant:
        if mappin.IsQuestMappin() {
          questMappin = mappin as QuestMappin;
          if IsDefined(questMappin) && questMappin.IsUIAnimation() {
          } else {
            if mappin.IsQuestEntityMappin() || mappin.IsQuestNPCMappin() {
              return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\minimap\\minimap_quest_mappin.inkwidget", t"MappinUISpawnProfile.Always", t"MinimapMappinUIProfile.Quest");
            };
          };
        } else {
          if customData != null && (customData as TrackedMappinControllerCustomData) != null {
            return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\minimap\\minimap_poi_mappin.inkwidget", t"MappinUISpawnProfile.Always", defaultRuntimeProfile);
          };
        };
        break;
      case gamedataMappinVariant.DefaultQuestVariant:
        if mappin.IsQuestMappin() {
          questMappin = mappin as QuestMappin;
          if IsDefined(questMappin) && questMappin.IsUIAnimation() {
          } else {
            if mappin.IsQuestEntityMappin() || mappin.IsQuestNPCMappin() {
              return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\minimap\\minimap_quest_mappin.inkwidget", t"MappinUISpawnProfile.Always", t"MinimapMappinUIProfile.Quest");
            };
          };
        } else {
          goto 1831;
        };
      case gamedataMappinVariant.HazardWarningVariant:
        return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\minimap\\minimap_hazard_warning_mappin.inkwidget", t"MappinUISpawnProfile.ShortRange", defaultRuntimeProfile);
      case gamedataMappinVariant.DynamicEventVariant:
        return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\minimap\\minimap_dynamic_event_mappin.inkwidget", t"MappinUISpawnProfile.MediumRange", defaultRuntimeProfile);
      case gamedataMappinVariant.CPO_RemotePlayerVariant:
        return MappinUIProfile.Create(r"multi\\gameplay\\gui\\widgets\\minimap\\minimap_remote_player_mappin.inkwidget", t"MappinUISpawnProfile.Always", t"MinimapMappinUIProfile.CPORemote");
      case gamedataMappinVariant.CPO_PingGoHereVariant:
        return MappinUIProfile.Create(r"multi\\gameplay\\gui\\widgets\\minimap\\minimap_pingsystem_mapping.inkwidget", t"MappinUISpawnProfile.Always", t"MinimapMappinUIProfile.CPORemote");
      default:
        if mappin.IsExactlyA(n"gamemappinsStealthMappin") {
          return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\minimap\\minimap_stealth_mappin.inkwidget", t"MappinUISpawnProfile.Stealth", t"MinimapMappinUIProfile.Stealth");
        };
    };
    if customData != null && (customData as TrackedMappinControllerCustomData) != null {
      return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\minimap\\minimap_poi_mappin.inkwidget", t"MappinUISpawnProfile.Always", defaultRuntimeProfile);
    };
    return MappinUIProfile.None();
  }

  private final func ZoneToState(zone: ESecurityAreaType) -> CName {
    switch zone {
      case ESecurityAreaType.SAFE:
        return n"Safe";
      case ESecurityAreaType.RESTRICTED:
        return n"Default";
      case ESecurityAreaType.DANGEROUS:
        return n"Dangerous";
    };
    return n"Default";
  }

  private final func ZoneToTextKey(zone: ESecurityAreaType) -> CName {
    switch zone {
      case ESecurityAreaType.SAFE:
        return n"Story-base-gameplay-gui-widgets-minimap-zones-Safe";
      case ESecurityAreaType.RESTRICTED:
        return n"Story-base-gameplay-gui-widgets-minimap-zones-Restricted";
      case ESecurityAreaType.DANGEROUS:
        return n"Story-base-gameplay-gui-widgets-minimap-zones-Hostile";
    };
    return n"Story-base-gameplay-gui-widgets-minimap-zones-Public";
  }
}
