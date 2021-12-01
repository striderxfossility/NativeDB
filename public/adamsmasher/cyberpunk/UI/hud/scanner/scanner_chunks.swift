
public class BaseChunkGameController extends inkGameController {

  protected let m_chunkBlackboard: wref<IBlackboard>;

  protected let m_chunkBlackboardDef: ref<UI_ScannerModulesDef>;

  protected let m_questClueBlackboardDef: ref<UI_ScannerDef>;

  protected cb func OnInitialize() -> Bool {
    this.m_chunkBlackboardDef = GetAllBlackboardDefs().UI_ScannerModules;
    this.m_chunkBlackboard = this.GetBlackboardSystem().Get(this.m_chunkBlackboardDef);
  }
}

public class ScannerNPCHeaderGameController extends BaseChunkGameController {

  private edit let m_nameText: inkTextRef;

  private edit let skullIndicator: inkWidgetRef;

  private edit let m_archetypeIcon: inkImageRef;

  private let m_levelCallbackID: ref<CallbackHandle>;

  private let m_nameCallbackID: ref<CallbackHandle>;

  private let m_attitudeCallbackID: ref<CallbackHandle>;

  private let m_archtypeCallbackID: ref<CallbackHandle>;

  private let m_isValidName: Bool;

  private let m_isValidRarity: Bool;

  private let m_isValidArchetype: Bool;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_nameCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerName, this, n"OnNameChanged");
    this.m_attitudeCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerAttitude, this, n"OnAttitudeChange");
    this.m_archtypeCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerArchetype, this, n"OnArchetypeChanged");
    this.m_levelCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerLevel, this, n"OnLevelChanged");
    this.OnNameChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerName));
    this.OnAttitudeChange(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerAttitude));
    this.OnArchetypeChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerArchetype));
    this.OnLevelChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerLevel));
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerName, this.m_nameCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerAttitude, this.m_attitudeCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerLevel, this.m_levelCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerArchetype, this.m_archtypeCallbackID);
  }

  protected cb func OnNameChanged(value: Variant) -> Bool {
    let displayNmae: String;
    let nameData: ref<ScannerName> = FromVariant(value);
    if IsDefined(nameData) {
      displayNmae = nameData.GetDisplayName();
      if IsStringValid(displayNmae) {
        if IsDefined(nameData.GetTextParams()) {
          inkTextRef.SetLocalizedTextScript(this.m_nameText, displayNmae, nameData.GetTextParams());
        } else {
          inkTextRef.SetText(this.m_nameText, displayNmae);
        };
        this.m_isValidName = true;
      } else {
        inkTextRef.SetText(this.m_nameText, "");
        this.m_isValidName = false;
      };
    } else {
      this.m_isValidName = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnLevelChanged(value: Variant) -> Bool {
    let levelData: ref<ScannerLevel> = FromVariant(value);
    inkWidgetRef.SetVisible(this.skullIndicator, levelData.GetIndicator());
  }

  protected cb func OnAttitudeChange(value: Variant) -> Bool {
    let attitudeData: ref<ScannerAttitude> = FromVariant(value);
    let attitude: EAIAttitude = attitudeData.GetAttitude();
    switch attitude {
      case EAIAttitude.AIA_Friendly:
        inkWidgetRef.SetState(this.m_nameText, n"Friendly");
        break;
      case EAIAttitude.AIA_Neutral:
        inkWidgetRef.SetState(this.m_nameText, n"Neutral");
        break;
      case EAIAttitude.AIA_Hostile:
        inkWidgetRef.SetState(this.m_nameText, n"Hostile");
    };
  }

  protected cb func OnArchetypeChanged(value: Variant) -> Bool {
    let archetype: gamedataArchetypeType;
    let iconRecord: ref<UIIcon_Record>;
    let archetypeData: ref<ScannerArchetype> = FromVariant(value);
    if IsDefined(archetypeData) {
      this.m_isValidArchetype = true;
      archetype = archetypeData.GetArchtype();
      iconRecord = TweakDBInterface.GetUIIconRecord(TDBID.Create("UIIcon." + ToString(archetype)));
      inkImageRef.SetTexturePart(this.m_archetypeIcon, iconRecord.AtlasPartName());
    } else {
      this.m_isValidArchetype = false;
    };
    this.UpdateGlobalVisibility();
  }

  private final func UpdateGlobalVisibility() -> Void {
    this.GetRootWidget().SetVisible(this.m_isValidName);
    inkWidgetRef.SetVisible(this.m_archetypeIcon, this.m_isValidArchetype);
  }
}

public class ScannerDeviceHeaderGameController extends BaseChunkGameController {

  private edit let m_nameText: inkTextRef;

  private edit let m_fluffText: inkTextRef;

  private edit let m_separator1: inkRectangleRef;

  private edit let m_separator2: inkRectangleRef;

  private edit let m_levelText: inkTextRef;

  private edit let m_status: inkTextRef;

  private edit let m_statusIcon: inkImageRef;

  private edit let m_levelWrapper: inkWidgetRef;

  private let m_nameCallbackID: ref<CallbackHandle>;

  private let m_networkLevelCallbackID: ref<CallbackHandle>;

  private let m_networkStatusCallbackID: ref<CallbackHandle>;

  private let m_deviceStatusCallbackID: ref<CallbackHandle>;

  private let m_attitudeCallbackID: ref<CallbackHandle>;

  private let m_isValidName: Bool;

  private let m_isValidNetworkLevel: Bool;

  private let m_isValidnetworkStatus: Bool;

  private let m_isValidDeviceStatus: Bool;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_nameCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerName, this, n"OnNameChanged");
    this.m_networkLevelCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerNetworkLevel, this, n"OnNetworkLevelChanged");
    this.m_networkStatusCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerNetworkStatus, this, n"OnNetworkStatusChanged");
    this.m_attitudeCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerAttitude, this, n"OnAttitudeChange");
    this.m_deviceStatusCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerDeviceStatus, this, n"OnDeviceStatusChange");
    this.OnNameChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerName));
    this.OnNetworkLevelChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerNetworkLevel));
    this.OnAttitudeChange(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerAttitude));
    this.OnDeviceStatusChange(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerDeviceStatus));
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerName, this.m_nameCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerNetworkLevel, this.m_networkLevelCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerNetworkStatus, this.m_nameCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerAttitude, this.m_attitudeCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerDeviceStatus, this.m_attitudeCallbackID);
  }

  protected cb func OnDeviceStatusChange(value: Variant) -> Bool {
    let deviceStatusData: ref<ScannerDeviceStatus> = FromVariant(value);
    if IsDefined(deviceStatusData) {
      inkTextRef.SetText(this.m_status, deviceStatusData.GetDeviceStatus());
      switch deviceStatusData.GetDeviceStatusFriendlyName() {
        case "disabled":
          inkImageRef.SetTexturePart(this.m_statusIcon, n"ico_device_disabled");
          break;
        case "unpowered":
          inkImageRef.SetTexturePart(this.m_statusIcon, n"ico_device_unpowered");
          break;
        case "off":
          inkImageRef.SetTexturePart(this.m_statusIcon, n"ico_device_off");
          break;
        case "on":
          inkImageRef.SetTexturePart(this.m_statusIcon, n"ico_device_on");
          break;
        default:
      };
      this.m_isValidDeviceStatus = true;
    } else {
      this.m_isValidDeviceStatus = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnNameChanged(value: Variant) -> Bool {
    let nameData: ref<ScannerName> = FromVariant(value);
    if IsDefined(nameData) {
      inkTextRef.SetLocalizedTextScript(this.m_nameText, nameData.GetDisplayName());
      this.m_isValidName = true;
    } else {
      this.m_isValidName = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnNetworkStatusChanged(value: Variant) -> Bool {
    let networkStatusData: ref<ScannerNetworkStatus> = FromVariant(value);
    if IsDefined(networkStatusData) {
      inkTextRef.SetText(this.m_levelText, ToString(networkStatusData.GetNetworkStatus()));
      this.m_isValidnetworkStatus = true;
    } else {
      this.m_isValidnetworkStatus = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnNetworkLevelChanged(value: Variant) -> Bool {
    let networkLevelData: ref<ScannerNetworkLevel> = FromVariant(value);
    if IsDefined(networkLevelData) && !this.m_isValidnetworkStatus && networkLevelData.GetNetworkLevel() > 0 {
      this.m_isValidNetworkLevel = true;
      inkTextRef.SetText(this.m_levelText, IntToString(networkLevelData.GetNetworkLevel()));
    } else {
      this.m_isValidNetworkLevel = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnAttitudeChange(value: Variant) -> Bool {
    let attitudeData: ref<ScannerAttitude> = FromVariant(value);
    let attitude: EAIAttitude = attitudeData.GetAttitude();
    switch attitude {
      case EAIAttitude.AIA_Friendly:
        inkWidgetRef.SetState(this.m_nameText, n"Friendly");
        inkWidgetRef.SetState(this.m_fluffText, n"Friendly");
        inkWidgetRef.SetState(this.m_separator1, n"Friendly");
        inkWidgetRef.SetState(this.m_separator2, n"Friendly");
        inkWidgetRef.SetState(this.m_levelText, n"Friendly");
        inkWidgetRef.SetState(this.m_levelWrapper, n"Friendly");
        break;
      case EAIAttitude.AIA_Neutral:
        inkWidgetRef.SetState(this.m_fluffText, n"Neutral");
        inkWidgetRef.SetState(this.m_separator1, n"Neutral");
        inkWidgetRef.SetState(this.m_separator2, n"Neutral");
        inkWidgetRef.SetState(this.m_nameText, n"Neutral");
        inkWidgetRef.SetState(this.m_levelText, n"Neutral");
        inkWidgetRef.SetState(this.m_levelWrapper, n"Neutral");
        break;
      case EAIAttitude.AIA_Hostile:
        inkWidgetRef.SetState(this.m_fluffText, n"Hostile");
        inkWidgetRef.SetState(this.m_separator1, n"Hostile");
        inkWidgetRef.SetState(this.m_separator2, n"Hostile");
        inkWidgetRef.SetState(this.m_nameText, n"Hostile");
        inkWidgetRef.SetState(this.m_levelText, n"Hostile");
        inkWidgetRef.SetState(this.m_levelWrapper, n"Hostile");
    };
  }

  private final func UpdateGlobalVisibility() -> Void {
    inkWidgetRef.SetVisible(this.m_levelWrapper, this.m_isValidNetworkLevel);
    inkWidgetRef.SetVisible(this.m_nameText, this.m_isValidName);
    inkWidgetRef.SetVisible(this.m_status, this.m_isValidDeviceStatus);
    inkWidgetRef.SetVisible(this.m_statusIcon, this.m_isValidDeviceStatus);
    this.GetRootWidget().SetVisible(this.m_isValidName || this.m_isValidNetworkLevel);
  }
}

public class ScannerNPCBodyGameController extends BaseChunkGameController {

  private edit let m_factionText: inkTextRef;

  private edit let m_dataBaseWidgetHolder: inkWidgetRef;

  private let m_factionCallbackID: ref<CallbackHandle>;

  private let m_rarityCallbackID: ref<CallbackHandle>;

  private let m_isValidFaction: Bool;

  private let m_asyncSpawnRequest: wref<inkAsyncSpawnRequest>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_factionCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerFaction, this, n"OnFactionChanged");
    this.m_rarityCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerRarity, this, n"OnRarityChanged");
    this.OnFactionChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerFaction));
    this.OnRarityChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerRarity));
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerFaction, this.m_factionCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerRarity, this.m_rarityCallbackID);
  }

  protected cb func OnFactionChanged(value: Variant) -> Bool {
    let factionData: ref<ScannerFaction> = FromVariant(value);
    if IsDefined(factionData) {
      inkTextRef.SetLocalizedTextScript(this.m_factionText, factionData.GetFaction());
      this.m_isValidFaction = true;
    } else {
      this.m_isValidFaction = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnRarityChanged(value: Variant) -> Bool {
    let rarityData: ref<ScannerRarity>;
    this.m_asyncSpawnRequest.Cancel();
    rarityData = FromVariant(value);
    if rarityData.IsCivilian() && !IsDefined(this.m_asyncSpawnRequest) {
      this.m_asyncSpawnRequest = this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_dataBaseWidgetHolder), n"ScannerCitizenDB", this, n"OnCitizenDBSpawned");
    };
  }

  protected cb func OnCitizenDBSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_asyncSpawnRequest = null;
  }

  private final func UpdateGlobalVisibility() -> Void {
    this.GetRootWidget().SetVisible(this.m_isValidFaction);
    inkWidgetRef.SetVisible(this.m_factionText, this.m_isValidFaction);
  }
}

public class ScannerDeviceBodyGameController extends BaseChunkGameController {

  private edit let m_networkStatusText: inkTextRef;

  private edit let m_deviceAuthorizationText: inkTextRef;

  private edit let m_deviceAuthorizationRow: inkCompoundRef;

  private edit let m_networkStatusRow: inkCompoundRef;

  private let m_networkStatusCallbackID: ref<CallbackHandle>;

  private let m_deviceAuthorizationCallbackID: ref<CallbackHandle>;

  private let m_isValidnetworkStatus: Bool;

  private let m_isValidDeviceAuthorization: Bool;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_networkStatusCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerNetworkStatus, this, n"OnNetworkStatusChanged");
    this.m_deviceAuthorizationCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerAuthorization, this, n"OnDeviceAuthorizationChanged");
    this.OnNetworkStatusChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerNetworkStatus));
    this.OnDeviceAuthorizationChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerAuthorization));
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerNetworkStatus, this.m_networkStatusCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerAuthorization, this.m_deviceAuthorizationCallbackID);
  }

  protected cb func OnNetworkStatusChanged(value: Variant) -> Bool {
    let networkStatusData: ref<ScannerNetworkStatus> = FromVariant(value);
    if IsDefined(networkStatusData) {
      if NotEquals(networkStatusData.GetNetworkStatus(), ScannerNetworkState.NOT_BREACHED) {
        inkTextRef.SetText(this.m_networkStatusText, ToString(networkStatusData.GetNetworkStatus()));
        this.m_isValidnetworkStatus = true;
      } else {
        this.m_isValidnetworkStatus = false;
      };
    } else {
      this.m_isValidnetworkStatus = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnDeviceAuthorizationChanged(value: Variant) -> Bool {
    let deviceAuthorizationData: ref<ScannerAuthorization> = FromVariant(value);
    if IsDefined(deviceAuthorizationData) {
      this.m_isValidDeviceAuthorization = true;
      if deviceAuthorizationData.ProtectedByKeycard() {
        inkTextRef.SetLocalizedTextScript(this.m_deviceAuthorizationText, "Gameplay-Devices-DisplayNames-Keycard");
      };
      if deviceAuthorizationData.ProtectedByPassword() {
        inkTextRef.SetLocalizedTextScript(this.m_deviceAuthorizationText, "Gameplay-Devices-DisplayNames-PasssodeRequired");
      };
    } else {
      this.m_isValidDeviceAuthorization = false;
    };
    this.UpdateGlobalVisibility();
  }

  private final func UpdateGlobalVisibility() -> Void {
    this.GetRootWidget().SetVisible(this.m_isValidnetworkStatus || this.m_isValidDeviceAuthorization);
    inkWidgetRef.SetVisible(this.m_networkStatusRow, this.m_isValidnetworkStatus);
    inkWidgetRef.SetVisible(this.m_deviceAuthorizationRow, this.m_isValidDeviceAuthorization);
  }
}

public class ScannerBountySystemGameController extends BaseChunkGameController {

  private edit let m_moneyReward: inkTextRef;

  private edit let m_moneyRewardRow: inkWidgetRef;

  private edit let m_streetCredReward: inkTextRef;

  private edit let m_streetCredRewardRow: inkWidgetRef;

  private edit let m_transgressions: inkTextRef;

  private edit let m_transgressionsWidget: inkWidgetRef;

  private edit let m_rewardPanel: inkCompoundRef;

  private edit let m_mugShot: inkRectangleRef;

  private edit let m_wanted: inkTextRef;

  private edit let m_notFound: inkTextRef;

  private edit let m_deadNotice: inkTextRef;

  private edit let m_crossedOut: inkWidgetRef;

  private edit const let starsWidget: array<inkWidgetRef>;

  private let m_bountyCallbackID: ref<CallbackHandle>;

  private let m_healthCallbackID: ref<CallbackHandle>;

  private let m_objectCallbackID: ref<CallbackHandle>;

  private let m_isValidBounty: Bool;

  private let m_isAlive: Bool;

  private let m_objectType: ScannerObjectType;

  private let m_showScanBountyAnimProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_bountyCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerBountySystem, this, n"OnBountySystemChanged");
    this.m_healthCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerHealth, this, n"OnHealthChanged");
    this.m_objectCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerInt(this.m_chunkBlackboardDef.ObjectType, this, n"OnObjectTypeChanged");
    this.OnObjectTypeChanged(this.m_chunkBlackboard.GetInt(this.m_chunkBlackboardDef.ObjectType));
    this.OnHealthChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerHealth));
    this.OnBountySystemChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerBountySystem));
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerBountySystem, this.m_bountyCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerHealth, this.m_healthCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ObjectType, this.m_objectCallbackID);
    this.m_showScanBountyAnimProxy.Stop();
  }

  protected cb func OnBountySystemChanged(value: Variant) -> Bool {
    let bountyStruct: BountyUI;
    let i: Int32;
    let limit: Int32;
    let transgressionsList: array<String>;
    let transgressionsText: String;
    let bountyData: ref<ScannerBountySystem> = FromVariant(value);
    this.m_isValidBounty = false;
    if this.IsNPC() {
      bountyStruct = bountyData.GetBounty();
      this.m_isValidBounty = true;
      if !bountyStruct.hasAccess {
        this.m_isValidBounty = false;
        return false;
      };
      if IsDefined(bountyData) {
        if this.m_isAlive {
          inkWidgetRef.SetVisible(this.m_rewardPanel, true);
          transgressionsList = bountyStruct.transgressions;
          limit = ArraySize(transgressionsList);
          if limit > 0 {
            inkWidgetRef.SetVisible(this.m_transgressionsWidget, true);
            if bountyStruct.streetCredReward > 0 {
              inkWidgetRef.SetVisible(this.m_streetCredRewardRow, true);
              inkTextRef.SetText(this.m_streetCredReward, IntToString(bountyStruct.streetCredReward));
            } else {
              inkWidgetRef.SetVisible(this.m_streetCredRewardRow, false);
            };
            if bountyStruct.moneyReward > 0 {
              inkWidgetRef.SetVisible(this.m_moneyRewardRow, true);
              inkTextRef.SetText(this.m_moneyReward, IntToString(bountyStruct.moneyReward));
            } else {
              inkWidgetRef.SetVisible(this.m_moneyRewardRow, false);
            };
            i = 0;
            while i < ArraySize(this.starsWidget) {
              if i < bountyStruct.level {
                inkWidgetRef.SetVisible(this.starsWidget[i], true);
              } else {
                inkWidgetRef.SetVisible(this.starsWidget[i], false);
              };
              i += 1;
            };
            i = 0;
            while i < limit {
              transgressionsText = transgressionsText + GetLocalizedText(transgressionsList[i]);
              if i < limit {
                transgressionsText = transgressionsText + " ; ";
              };
              i += 1;
            };
            inkTextRef.SetText(this.m_transgressions, transgressionsText);
          } else {
            inkWidgetRef.SetVisible(this.m_transgressionsWidget, false);
          };
          this.ProcessBountyTutorial();
        } else {
          inkWidgetRef.SetVisible(this.m_transgressionsWidget, false);
          inkTextRef.SetLocalizedTextScript(this.m_wanted, "LocKey#40654");
          inkWidgetRef.SetVisible(this.m_mugShot, false);
        };
      } else {
        this.m_isValidBounty = true;
        inkWidgetRef.SetVisible(this.m_transgressionsWidget, false);
        inkWidgetRef.SetVisible(this.m_rewardPanel, false);
        inkWidgetRef.SetVisible(this.m_notFound, true);
        inkTextRef.SetLocalizedTextScript(this.m_notFound, "LocKey#40655");
        inkWidgetRef.SetVisible(this.m_mugShot, false);
        inkWidgetRef.SetVisible(this.m_wanted, false);
      };
    };
    this.UpdateGlobalVisibility();
  }

  private final func ProcessBountyTutorial() -> Void {
    let questsSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem((this.GetOwnerEntity() as GameObject).GetGame());
    if questsSystem.GetFact(n"tutorial_scanner_bounty_displayed") == 0 {
      questsSystem.SetFact(n"tutorial_scanner_bounty_displayed", 1);
    };
  }

  protected cb func OnHealthChanged(value: Variant) -> Bool {
    let healthData: ref<ScannerHealth> = FromVariant(value);
    this.m_isAlive = healthData.GetCurrentHealth() > 0;
    this.UpdateGlobalVisibility();
  }

  protected cb func OnObjectTypeChanged(value: Int32) -> Bool {
    this.m_objectType = IntEnum(value);
  }

  private final func IsNPC() -> Bool {
    return Equals(this.m_objectType, ScannerObjectType.PUPPET) ? true : false;
  }

  private final func UpdateGlobalVisibility() -> Void {
    this.GetRootWidget().SetVisible(this.m_isValidBounty);
    this.m_showScanBountyAnimProxy = this.PlayLibraryAnimation(n"bounty");
  }
}

public class ScannerVulnerabilitiesGameController extends BaseChunkGameController {

  private edit let m_ScannerVulnerabilitiesRightPanel: inkCompoundRef;

  private let m_vulnerabilitiesCallbackID: ref<CallbackHandle>;

  private let m_isValidVulnerabilities: Bool;

  private let m_asyncSpawnRequests: array<wref<inkAsyncSpawnRequest>>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_vulnerabilitiesCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerVulnerabilities, this, n"OnVulnerabilitiesChanged");
    this.OnVulnerabilitiesChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerVulnerabilities));
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerVulnerabilities, this.m_vulnerabilitiesCallbackID);
  }

  protected cb func OnVulnerabilitiesChanged(value: Variant) -> Bool {
    let asyncSpawnRequest: wref<inkAsyncSpawnRequest>;
    let i: Int32;
    let limit: Int32;
    let vulnerabilitiesList: array<Vulnerability>;
    let vulnerabilityStruct: Vulnerability;
    let vulnerabilityUserData: ref<VulnerabilityUserData>;
    let vulnerabilitiesData: ref<ScannerVulnerabilities> = FromVariant(value);
    this.ClearAllAsyncSpawnRequests();
    if IsDefined(vulnerabilitiesData) {
      vulnerabilitiesList = vulnerabilitiesData.GetVulnerabilities();
      limit = ArraySize(vulnerabilitiesList);
      i = 0;
      while i < limit {
        vulnerabilityStruct = vulnerabilitiesList[i];
        vulnerabilityUserData = new VulnerabilityUserData();
        vulnerabilityUserData.vulnerabilityName = vulnerabilityStruct.vulnerabilityName;
        vulnerabilityUserData.icon = vulnerabilityStruct.icon;
        vulnerabilityUserData.isActive = vulnerabilityStruct.isActive;
        asyncSpawnRequest = this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_ScannerVulnerabilitiesRightPanel), n"ScannerVulnerabilityItemWidget", this, n"OnVulnerabilitySpawned", vulnerabilityUserData);
        vulnerabilityUserData.asyncSpawnRequest = asyncSpawnRequest;
        ArrayPush(this.m_asyncSpawnRequests, asyncSpawnRequest);
        i += 1;
      };
      this.m_isValidVulnerabilities = true;
    } else {
      this.m_isValidVulnerabilities = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnVulnerabilitySpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let vulnerabilityUserData: ref<VulnerabilityUserData> = userData as VulnerabilityUserData;
    if IsDefined(vulnerabilityUserData) {
      this.ClearAsyncSpawnRequest(vulnerabilityUserData.asyncSpawnRequest);
      (widget.GetController() as ScannerVulnerabilityItemLogicController).Setup(userData);
    };
  }

  private final func UpdateGlobalVisibility() -> Void {
    this.GetRootWidget().SetVisible(this.m_isValidVulnerabilities);
  }

  private final func ClearAsyncSpawnRequest(request: wref<inkAsyncSpawnRequest>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_asyncSpawnRequests) {
      if this.m_asyncSpawnRequests[i] == request {
        this.m_asyncSpawnRequests[i] = null;
        ArrayErase(this.m_asyncSpawnRequests, i);
      } else {
        i += 1;
      };
    };
  }

  private final func ClearAllAsyncSpawnRequests() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_asyncSpawnRequests) {
      this.m_asyncSpawnRequests[i].Cancel();
      this.m_asyncSpawnRequests[i] = null;
      i += 1;
    };
    ArrayClear(this.m_asyncSpawnRequests);
  }
}

public class ScannerVulnerabilityItemLogicController extends inkLogicController {

  private edit let m_vulnerabilityNameText: inkTextRef;

  private edit let m_vulnerabilityIcon: inkImageRef;

  public final func Setup(vulnerability: ref<IScriptable>) -> Void {
    let iconRecord: ref<UIIcon_Record>;
    let vulnerabilityUserData: ref<VulnerabilityUserData> = vulnerability as VulnerabilityUserData;
    inkTextRef.SetLocalizedTextScript(this.m_vulnerabilityNameText, vulnerabilityUserData.vulnerabilityName);
    iconRecord = TweakDBInterface.GetUIIconRecord(TDBID.Create("UIIcon." + NameToString(vulnerabilityUserData.icon)));
    inkImageRef.SetAtlasResource(this.m_vulnerabilityIcon, iconRecord.AtlasResourcePath());
    inkImageRef.SetTexturePart(this.m_vulnerabilityIcon, iconRecord.AtlasPartName());
    if !vulnerabilityUserData.isActive {
      inkWidgetRef.SetState(this.m_vulnerabilityNameText, n"Failed");
      inkWidgetRef.SetState(this.m_vulnerabilityIcon, n"Failed");
    } else {
      inkWidgetRef.SetState(this.m_vulnerabilityNameText, n"Passed");
      inkWidgetRef.SetState(this.m_vulnerabilityIcon, n"Passed");
    };
  }
}

public class ScannerAbilitiesGameController extends BaseChunkGameController {

  private edit let m_ScannerAbilitiesRightPanel: inkCompoundRef;

  private let m_abilitiesCallbackID: ref<CallbackHandle>;

  private let m_isValidAbilities: Bool;

  private let m_asyncSpawnRequests: array<wref<inkAsyncSpawnRequest>>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_abilitiesCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerAbilities, this, n"OnAbilitiesChanged");
    this.OnAbilitiesChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerAbilities));
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerAbilities, this.m_abilitiesCallbackID);
  }

  protected cb func OnAbilitiesChanged(value: Variant) -> Bool {
    let abilitiesList: array<wref<GameplayAbility_Record>>;
    let abilityData: ref<AbilityUserData>;
    let abilityStruct: ref<GameplayAbility_Record>;
    let asyncSpawnRequest: wref<inkAsyncSpawnRequest>;
    let i: Int32;
    let limit: Int32;
    let abilitiesData: ref<ScannerAbilities> = FromVariant(value);
    this.ClearAllAsyncSpawnRequests();
    if IsDefined(abilitiesData) {
      abilitiesList = abilitiesData.GetAbilities();
      limit = ArraySize(abilitiesList);
      i = 0;
      while i < limit {
        abilityStruct = abilitiesList[i];
        if abilityStruct.ShowInCodex() {
          abilityData = new AbilityUserData();
          abilityData.abilityID = abilityStruct.GetID();
          abilityData.locKeyName = abilityStruct.Loc_key_name();
          asyncSpawnRequest = this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_ScannerAbilitiesRightPanel), n"ScannerAbilityItemWidget", this, n"OnAbilitySpawned", abilityData);
          abilityData.asyncSpawnRequest = asyncSpawnRequest;
          ArrayPush(this.m_asyncSpawnRequests, asyncSpawnRequest);
        };
        i += 1;
      };
      this.m_isValidAbilities = true;
    } else {
      this.m_isValidAbilities = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnAbilitySpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let abilityData: ref<AbilityUserData> = userData as AbilityUserData;
    if IsDefined(abilityData) {
      this.ClearAsyncSpawnRequest(abilityData.asyncSpawnRequest);
      (widget.GetController() as ScannerAbilityItemLogicController).Setup(userData);
    };
  }

  private final func ClearAsyncSpawnRequest(request: wref<inkAsyncSpawnRequest>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_asyncSpawnRequests) {
      if this.m_asyncSpawnRequests[i] == request {
        this.m_asyncSpawnRequests[i] = null;
        ArrayErase(this.m_asyncSpawnRequests, i);
      } else {
        i += 1;
      };
    };
  }

  private final func ClearAllAsyncSpawnRequests() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_asyncSpawnRequests) {
      this.m_asyncSpawnRequests[i].Cancel();
      this.m_asyncSpawnRequests[i] = null;
      i += 1;
    };
    ArrayClear(this.m_asyncSpawnRequests);
  }

  private final func UpdateGlobalVisibility() -> Void {
    this.GetRootWidget().SetVisible(this.m_isValidAbilities);
  }
}

public class ScannerAbilityItemLogicController extends inkLogicController {

  private edit let m_abilityNameText: inkTextRef;

  private edit let m_abilityIcon: inkImageRef;

  public final func Setup(ability: ref<IScriptable>) -> Void {
    let iconRecord: ref<UIIcon_Record>;
    let abilityData: ref<AbilityUserData> = ability as AbilityUserData;
    let iconPrefix: String = "UIIcon.";
    let iconName: TweakDBID = TDBID.Create(iconPrefix);
    TDBID.Append(iconName, abilityData.abilityID);
    inkTextRef.SetLocalizedTextScript(this.m_abilityNameText, abilityData.locKeyName);
    iconRecord = TweakDBInterface.GetUIIconRecord(iconName);
    inkImageRef.SetTexturePart(this.m_abilityIcon, iconRecord.AtlasPartName());
  }
}

public class ScannerResistancesGameController extends BaseChunkGameController {

  private edit let m_physicalResistText: inkTextRef;

  private edit let m_physicalResistContainer: inkCompoundRef;

  private edit let m_thermalResistText: inkTextRef;

  private edit let m_thermalResistContainer: inkCompoundRef;

  private edit let m_chemicalResistText: inkTextRef;

  private edit let m_chemicalResistContainer: inkCompoundRef;

  private edit let m_electricResistText: inkTextRef;

  private edit let m_electricResistContainer: inkCompoundRef;

  private edit let m_hackingResistText: inkTextRef;

  private edit let m_hackingResistContainer: inkCompoundRef;

  private edit let m_physicalWeaknessText: inkTextRef;

  private edit let m_physicalWeaknessContainer: inkCompoundRef;

  private edit let m_thermalWeaknessText: inkTextRef;

  private edit let m_thermalWeaknessContainer: inkCompoundRef;

  private edit let m_chemicalWeaknessText: inkTextRef;

  private edit let m_chemicalWeaknessContainer: inkCompoundRef;

  private edit let m_electricWeaknessText: inkTextRef;

  private edit let m_electricWeaknessContainer: inkCompoundRef;

  private edit let m_hackingWeaknessText: inkTextRef;

  private edit let m_hackingWeaknessContainer: inkCompoundRef;

  private edit let m_leftPanel: inkCompoundRef;

  private edit let m_rightPanel: inkCompoundRef;

  private let m_resistancesCallbackID: ref<CallbackHandle>;

  private let m_isValidResistances: Bool;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_resistancesCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerResistances, this, n"OnResistancesChanged");
    this.OnResistancesChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerResistances));
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerResistances, this.m_resistancesCallbackID);
  }

  protected cb func OnResistancesChanged(value: Variant) -> Bool {
    let chemicalResistanceValue: Int32;
    let electricResistanceValue: Int32;
    let hackingBaseValue: Int32;
    let hackingResistanceValue: Int32;
    let i: Int32;
    let physicalResistanceValue: Int32;
    let resistancesList: array<ScannerStatDetails>;
    let thermalResistanceValue: Int32;
    let resistanceData: ref<ScannerResistances> = FromVariant(value);
    if IsDefined(resistanceData) {
      resistancesList = resistanceData.GetResistances();
      inkWidgetRef.SetVisible(this.m_leftPanel, false);
      inkWidgetRef.SetVisible(this.m_rightPanel, false);
      inkWidgetRef.SetVisible(this.m_physicalResistContainer, false);
      inkWidgetRef.SetVisible(this.m_thermalResistContainer, false);
      inkWidgetRef.SetVisible(this.m_chemicalResistContainer, false);
      inkWidgetRef.SetVisible(this.m_electricResistContainer, false);
      inkWidgetRef.SetVisible(this.m_hackingResistContainer, false);
      inkWidgetRef.SetVisible(this.m_physicalWeaknessContainer, false);
      inkWidgetRef.SetVisible(this.m_thermalWeaknessContainer, false);
      inkWidgetRef.SetVisible(this.m_chemicalWeaknessContainer, false);
      inkWidgetRef.SetVisible(this.m_electricWeaknessContainer, false);
      inkWidgetRef.SetVisible(this.m_hackingWeaknessContainer, false);
      i = 0;
      while i < ArraySize(resistancesList) {
        switch resistancesList[i].statType {
          case gamedataStatType.PhysicalResistance:
            physicalResistanceValue = Cast(resistancesList[i].value);
            if physicalResistanceValue > 0 {
              inkWidgetRef.SetVisible(this.m_rightPanel, true);
              inkWidgetRef.SetVisible(this.m_physicalResistContainer, true);
              inkTextRef.SetText(this.m_physicalResistText, Abs(physicalResistanceValue) + " %");
              this.m_isValidResistances = true;
            } else {
              if physicalResistanceValue < 0 {
                inkWidgetRef.SetVisible(this.m_leftPanel, true);
                inkWidgetRef.SetVisible(this.m_physicalWeaknessContainer, true);
                inkTextRef.SetText(this.m_physicalWeaknessText, Abs(physicalResistanceValue) + " %");
                this.m_isValidResistances = true;
              } else {
                inkWidgetRef.SetVisible(this.m_physicalResistContainer, false);
                inkWidgetRef.SetVisible(this.m_physicalWeaknessContainer, false);
              };
            };
            break;
          case gamedataStatType.ThermalResistance:
            thermalResistanceValue = Cast(resistancesList[i].value);
            if thermalResistanceValue > 0 {
              inkWidgetRef.SetVisible(this.m_rightPanel, true);
              inkWidgetRef.SetVisible(this.m_thermalResistContainer, true);
              inkTextRef.SetText(this.m_thermalResistText, Abs(thermalResistanceValue) + " %");
              this.m_isValidResistances = true;
            } else {
              if thermalResistanceValue < 0 {
                inkWidgetRef.SetVisible(this.m_leftPanel, true);
                inkWidgetRef.SetVisible(this.m_thermalWeaknessContainer, true);
                inkTextRef.SetText(this.m_thermalWeaknessText, Abs(thermalResistanceValue) + " %");
                this.m_isValidResistances = true;
              } else {
                inkWidgetRef.SetVisible(this.m_thermalResistContainer, false);
                inkWidgetRef.SetVisible(this.m_thermalWeaknessContainer, false);
              };
            };
            break;
          case gamedataStatType.ElectricResistance:
            electricResistanceValue = Cast(resistancesList[i].value);
            if electricResistanceValue > 0 {
              inkWidgetRef.SetVisible(this.m_rightPanel, true);
              inkWidgetRef.SetVisible(this.m_electricResistContainer, true);
              inkTextRef.SetText(this.m_electricResistText, Abs(electricResistanceValue) + " %");
              this.m_isValidResistances = true;
            } else {
              if electricResistanceValue < 0 {
                inkWidgetRef.SetVisible(this.m_leftPanel, true);
                inkWidgetRef.SetVisible(this.m_electricWeaknessContainer, true);
                inkTextRef.SetText(this.m_electricWeaknessText, Abs(electricResistanceValue) + " %");
                this.m_isValidResistances = true;
              } else {
                inkWidgetRef.SetVisible(this.m_electricResistContainer, false);
                inkWidgetRef.SetVisible(this.m_electricWeaknessContainer, false);
              };
            };
            break;
          case gamedataStatType.ChemicalResistance:
            chemicalResistanceValue = Cast(resistancesList[i].value);
            if chemicalResistanceValue > 0 {
              inkWidgetRef.SetVisible(this.m_rightPanel, true);
              inkWidgetRef.SetVisible(this.m_chemicalResistContainer, true);
              inkTextRef.SetText(this.m_chemicalResistText, Abs(chemicalResistanceValue) + " %");
              this.m_isValidResistances = true;
            } else {
              if chemicalResistanceValue < 0 {
                inkWidgetRef.SetVisible(this.m_leftPanel, true);
                inkWidgetRef.SetVisible(this.m_chemicalWeaknessContainer, true);
                inkTextRef.SetText(this.m_chemicalWeaknessText, Abs(chemicalResistanceValue) + " %");
                this.m_isValidResistances = true;
              } else {
                inkWidgetRef.SetVisible(this.m_chemicalResistContainer, false);
                inkWidgetRef.SetVisible(this.m_chemicalWeaknessContainer, false);
              };
            };
            break;
          case gamedataStatType.HackingResistance:
            hackingResistanceValue = Cast(resistancesList[i].value);
            hackingBaseValue = Cast(resistancesList[i].baseValue);
            if hackingBaseValue > 0 && hackingResistanceValue > 0 {
              inkWidgetRef.SetVisible(this.m_rightPanel, true);
              inkWidgetRef.SetVisible(this.m_hackingResistContainer, true);
              inkTextRef.SetText(this.m_hackingResistText, "+" + ToString(Abs(hackingResistanceValue)));
              this.m_isValidResistances = true;
            } else {
              if hackingBaseValue < 0 && hackingResistanceValue < 0 {
                inkWidgetRef.SetVisible(this.m_leftPanel, true);
                inkWidgetRef.SetVisible(this.m_hackingWeaknessContainer, true);
                inkTextRef.SetText(this.m_hackingWeaknessText, "-" + ToString(Abs(hackingResistanceValue)));
                this.m_isValidResistances = true;
              } else {
                inkWidgetRef.SetVisible(this.m_hackingResistContainer, false);
                inkWidgetRef.SetVisible(this.m_hackingWeaknessContainer, false);
              };
            };
            break;
          default:
            this.m_isValidResistances = false;
        };
        i += 1;
      };
    } else {
      this.m_isValidResistances = false;
    };
    this.UpdateGlobalVisibility();
  }

  private final func UpdateGlobalVisibility() -> Void {
    this.GetRootWidget().SetVisible(this.m_isValidResistances);
  }
}

public class ScannerDescriptionGameController extends BaseChunkGameController {

  private edit let m_descriptionText: inkTextRef;

  private edit let m_customDescriptionText: inkTextRef;

  private let m_descriptionCallbackID: ref<CallbackHandle>;

  private let m_isValidDescription: Bool;

  private let m_isValidCustomDescription: Bool;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_descriptionCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerDescription, this, n"OnDescriptionChanged");
    this.OnDescriptionChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerDescription));
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerDescription, this.m_descriptionCallbackID);
  }

  protected cb func OnDescriptionChanged(value: Variant) -> Bool {
    let customDescriptionsConcatenated: String;
    let i: Int32;
    let descriptionData: ref<ScannerDescription> = FromVariant(value);
    let defaultFluffDescription: String = descriptionData.GetDefaultDescription();
    let customDescriptions: array<String> = descriptionData.GetCustomDescriptions();
    if Equals(defaultFluffDescription, "") && ArraySize(customDescriptions) == 0 {
      this.m_isValidDescription = false;
    };
    if NotEquals(defaultFluffDescription, "") {
      inkTextRef.SetLocalizedTextScript(this.m_descriptionText, defaultFluffDescription);
      this.m_isValidDescription = true;
    };
    if ArraySize(customDescriptions) > 0 {
      i = 0;
      while i < ArraySize(customDescriptions) {
        if i > 0 {
          customDescriptionsConcatenated = customDescriptionsConcatenated + "\\n";
        };
        customDescriptionsConcatenated = customDescriptionsConcatenated + customDescriptions[i];
        i += 1;
      };
      inkTextRef.SetLocalizedTextScript(this.m_customDescriptionText, customDescriptionsConcatenated);
      this.m_isValidCustomDescription = true;
    };
    this.UpdateGlobalVisibility();
  }

  private final func UpdateGlobalVisibility() -> Void {
    this.GetRootWidget().SetVisible(this.m_isValidDescription || this.m_isValidCustomDescription);
    inkWidgetRef.SetVisible(this.m_descriptionText, this.m_isValidDescription);
    inkWidgetRef.SetVisible(this.m_customDescriptionText, this.m_isValidCustomDescription);
  }
}

public class ScannerRequirementsGameController extends BaseChunkGameController {

  private edit let m_ScannerRequirementsRightPanel: inkCompoundRef;

  private let m_requirementsCallbackID: ref<CallbackHandle>;

  private let m_isValidRequirements: Bool;

  private let m_asyncSpawnRequests: array<wref<inkAsyncSpawnRequest>>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_requirementsCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerSkillChecks, this, n"OnRequirementsChanged");
    this.OnRequirementsChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerSkillChecks));
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerSkillChecks, this.m_requirementsCallbackID);
  }

  protected cb func OnRequirementsChanged(value: Variant) -> Bool {
    let asyncSpawnRequest: wref<inkAsyncSpawnRequest>;
    let i: Int32;
    let limit: Int32;
    let requirementList: array<UIInteractionSkillCheck>;
    let requirementStruct: UIInteractionSkillCheck;
    let requirementUserData: ref<RequirementUserData>;
    let requirementsData: ref<ScannerSkillchecks> = FromVariant(value);
    this.ClearAllAsyncSpawnRequests();
    if IsDefined(requirementsData) {
      requirementList = requirementsData.GetSkillchecks();
      limit = ArraySize(requirementList);
      i = 0;
      while i < limit {
        requirementStruct = requirementList[i];
        requirementUserData = new RequirementUserData();
        requirementUserData.skillName = requirementStruct.skillName;
        requirementUserData.requiredSkill = requirementStruct.requiredSkill;
        requirementUserData.skillCheck = requirementStruct.skillCheck;
        requirementUserData.isPassed = requirementStruct.isPassed;
        asyncSpawnRequest = this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_ScannerRequirementsRightPanel), n"ScannerRequirementItemWidget", this, n"OnRequirementSpawned", requirementUserData);
        requirementUserData.asyncSpawnRequest = asyncSpawnRequest;
        ArrayPush(this.m_asyncSpawnRequests, asyncSpawnRequest);
        i += 1;
      };
      this.m_isValidRequirements = true;
    } else {
      this.m_isValidRequirements = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnRequirementSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let requirementUserData: ref<RequirementUserData> = userData as RequirementUserData;
    if IsDefined(requirementUserData) {
      this.ClearAsyncSpawnRequest(requirementUserData.asyncSpawnRequest);
      (widget.GetController() as ScannerRequirementItemLogicController).Setup(userData);
    };
  }

  private final func UpdateGlobalVisibility() -> Void {
    this.GetRootWidget().SetVisible(this.m_isValidRequirements);
  }

  private final func ClearAsyncSpawnRequest(request: wref<inkAsyncSpawnRequest>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_asyncSpawnRequests) {
      if this.m_asyncSpawnRequests[i] == request {
        this.m_asyncSpawnRequests[i] = null;
        ArrayErase(this.m_asyncSpawnRequests, i);
      } else {
        i += 1;
      };
    };
  }

  private final func ClearAllAsyncSpawnRequests() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_asyncSpawnRequests) {
      this.m_asyncSpawnRequests[i].Cancel();
      this.m_asyncSpawnRequests[i] = null;
      i += 1;
    };
    ArrayClear(this.m_asyncSpawnRequests);
  }
}

public class ScannerRequirementItemLogicController extends inkLogicController {

  private edit let m_requirementNameText: inkTextRef;

  private edit let m_requirementLevelText: inkTextRef;

  private edit let m_requirementIcon: inkImageRef;

  private let m_skillCheck: EDeviceChallengeSkill;

  private let requirementUserData: ref<RequirementUserData>;

  public final func Setup(requirement: ref<IScriptable>) -> Void {
    this.requirementUserData = requirement as RequirementUserData;
    inkTextRef.SetLocalizedTextScript(this.m_requirementNameText, this.requirementUserData.skillName);
    inkTextRef.SetText(this.m_requirementLevelText, "[ " + ToString(this.requirementUserData.requiredSkill) + " ]");
    this.m_skillCheck = this.requirementUserData.skillCheck;
    switch this.m_skillCheck {
      case EDeviceChallengeSkill.Hacking:
        inkImageRef.SetTexturePart(this.m_requirementIcon, n"ico_int");
        break;
      case EDeviceChallengeSkill.Engineering:
        inkImageRef.SetTexturePart(this.m_requirementIcon, n"ico_tech");
        break;
      case EDeviceChallengeSkill.Athletics:
        inkImageRef.SetTexturePart(this.m_requirementIcon, n"ico_body");
        break;
      case EDeviceChallengeSkill.Invalid:
        inkImageRef.SetTexturePart(this.m_requirementIcon, n"ico_cool");
        break;
      default:
        inkImageRef.SetTexturePart(this.m_requirementIcon, n"ico_body");
    };
    if !this.requirementUserData.isPassed {
      inkWidgetRef.SetState(this.m_requirementNameText, n"inactive");
      inkWidgetRef.SetState(this.m_requirementIcon, n"inactive");
      inkWidgetRef.SetState(this.m_requirementLevelText, n"inactive");
    };
  }
}

public class ScannerQuestCluesGameController extends BaseChunkGameController {

  private edit let m_ScannerQuestPanel: inkCompoundRef;

  private let m_questCluesCallbackID: ref<CallbackHandle>;

  private let m_scannerDataCallbackID: ref<CallbackHandle>;

  private let m_isValidQuestClues: Bool;

  private let m_ScannerData: scannerDataStructure;

  private let m_hasValidScannables: Bool;

  private let m_asyncSpawnRequests: array<wref<inkAsyncSpawnRequest>>;

  protected cb func OnInitialize() -> Bool {
    this.m_questClueBlackboardDef = GetAllBlackboardDefs().UI_Scanner;
    this.m_chunkBlackboard = this.GetBlackboardSystem().Get(this.m_questClueBlackboardDef);
    this.m_questCluesCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_questClueBlackboardDef.Scannables, this, n"OnQuestCluesChanged");
    this.m_scannerDataCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_questClueBlackboardDef.scannerData, this, n"OnScannerDataChange");
    this.OnQuestCluesChanged(this.m_chunkBlackboard.GetVariant(this.m_questClueBlackboardDef.Scannables));
    this.OnScannerDataChange(this.m_chunkBlackboard.GetVariant(this.m_questClueBlackboardDef.scannerData));
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_chunkBlackboard.UnregisterDelayedListener(this.m_questClueBlackboardDef.Scannables, this.m_questCluesCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(this.m_questClueBlackboardDef.scannerData, this.m_scannerDataCallbackID);
  }

  protected cb func OnScannerDataChange(val: Variant) -> Bool {
    if VariantIsValid(val) {
      this.m_ScannerData = FromVariant(val);
    };
    this.Refresh();
  }

  protected cb func OnQuestCluesChanged(value: Variant) -> Bool {
    let i: Int32;
    let questEntry: scannerQuestEntry;
    let scannables: array<ScanningTooltipElementData>;
    if VariantIsValid(value) {
      scannables = FromVariant(value);
    };
    ArrayClear(this.m_ScannerData.questEntries);
    if ArraySize(scannables) > 0 {
      i = 0;
      while i < ArraySize(scannables) {
        questEntry.categoryName = scannables[i].localizedName;
        questEntry.entryName = scannables[i].localizedDescription;
        questEntry.recordID = scannables[i].recordID;
        ArrayPush(this.m_ScannerData.questEntries, questEntry);
        i += 1;
      };
    };
    this.m_hasValidScannables = false;
    i = 0;
    while i < ArraySize(scannables) {
      if TDBID.IsValid(scannables[i].recordID) {
        this.m_hasValidScannables = true;
      } else {
        i += 1;
      };
    };
    this.Refresh();
  }

  private final func Refresh() -> Void {
    let asyncSpawnRequest: wref<inkAsyncSpawnRequest>;
    let limit: Int32;
    let questEntry: scannerQuestEntry;
    let questEntryUserData: ref<QuestEntryUserData>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_asyncSpawnRequests) {
      this.m_asyncSpawnRequests[i].Cancel();
      this.m_asyncSpawnRequests[i] = null;
      i += 1;
    };
    ArrayClear(this.m_asyncSpawnRequests);
    limit = ArraySize(this.m_ScannerData.questEntries);
    inkCompoundRef.RemoveAllChildren(this.m_ScannerQuestPanel);
    inkWidgetRef.SetVisible(this.m_ScannerQuestPanel, this.m_hasValidScannables && limit > 0);
    i = 0;
    while i < limit {
      questEntry = this.m_ScannerData.questEntries[i];
      questEntryUserData = new QuestEntryUserData();
      questEntryUserData.categoryName = questEntry.categoryName;
      questEntryUserData.entryName = questEntry.entryName;
      questEntryUserData.recordID = questEntry.recordID;
      asyncSpawnRequest = this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_ScannerQuestPanel), n"questDescription", this, n"OnQuestEntrySpawned", questEntryUserData);
      questEntryUserData.asyncSpawnRequest = asyncSpawnRequest;
      ArrayPush(this.m_asyncSpawnRequests, asyncSpawnRequest);
      i += 1;
    };
  }

  protected cb func OnQuestEntrySpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let questEntryUserData: ref<QuestEntryUserData> = userData as QuestEntryUserData;
    if IsDefined(questEntryUserData) {
      this.ClearAsyncSpawnRequest(questEntryUserData.asyncSpawnRequest);
      (widget.GetController() as ScannerQuestClue).Setup(userData);
    };
  }

  private final func UpdateGlobalVisibility() -> Void {
    this.GetRootWidget().SetVisible(this.m_hasValidScannables);
  }

  private final func ClearAsyncSpawnRequest(request: wref<inkAsyncSpawnRequest>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_asyncSpawnRequests) {
      if this.m_asyncSpawnRequests[i] == request {
        this.m_asyncSpawnRequests[i] = null;
        ArrayErase(this.m_asyncSpawnRequests, i);
      } else {
        i += 1;
      };
    };
  }
}

public class ScannervehicleGameController extends BaseChunkGameController {

  private let m_vehicleNameCallbackID: ref<CallbackHandle>;

  private let m_vehicleManufacturerCallbackID: ref<CallbackHandle>;

  private let m_vehicleProdYearsCallbackID: ref<CallbackHandle>;

  private let m_vehicleDriveLayoutCallbackID: ref<CallbackHandle>;

  private let m_vehicleHorsepowerCallbackID: ref<CallbackHandle>;

  private let m_vehicleMassCallbackID: ref<CallbackHandle>;

  private let m_vehicleStateCallbackID: ref<CallbackHandle>;

  private let m_vehicleInfoCallbackID: ref<CallbackHandle>;

  private let m_isValidVehicleManufacturer: Bool;

  private let m_isValidVehicleName: Bool;

  private let m_isValidVehicleProdYears: Bool;

  private let m_isValidVehicleDriveLayout: Bool;

  private let m_isValidVehicleHorsepower: Bool;

  private let m_isValidVehicleMass: Bool;

  private let m_isValidVehicleState: Bool;

  private let m_isValidVehicleInfo: Bool;

  private edit let m_vehicleNameText: inkTextRef;

  private edit let m_vehicleManufacturer: inkImageRef;

  private edit let m_vehicleProdYearsText: inkTextRef;

  private edit let m_vehicleDriveLayoutText: inkTextRef;

  private edit let m_vehicleHorsepowerText: inkTextRef;

  private edit let m_vehicleMassText: inkTextRef;

  private edit let m_vehicleStateText: inkTextRef;

  private edit let m_vehicleInfoText: inkTextRef;

  private edit let m_vehicleNameHolder: inkWidgetRef;

  private edit let m_vehicleProdYearsHolder: inkWidgetRef;

  private edit let m_vehicleDriveLayoutHolder: inkWidgetRef;

  private edit let m_vehicleHorsepowerHolder: inkWidgetRef;

  private edit let m_vehicleMassHolder: inkWidgetRef;

  private edit let m_vehicleStateHolder: inkWidgetRef;

  private edit let m_vehicleInfoHolder: inkWidgetRef;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_vehicleNameCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerVehicleName, this, n"OnVehicleNameChanged");
    this.m_vehicleManufacturerCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerVehicleManufacturer, this, n"OnVehicleNameChanged");
    this.m_vehicleProdYearsCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerVehicleProductionYears, this, n"OnVehicleProdYearsChanged");
    this.m_vehicleDriveLayoutCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerVehicleDriveLayout, this, n"OnVehicleeDriveLayoutChanged");
    this.m_vehicleHorsepowerCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerVehicleHorsepower, this, n"OnVehicleHorsepowerChanged");
    this.m_vehicleMassCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerVehicleMass, this, n"OnVehicleMassChanged");
    this.m_vehicleStateCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerVehicleState, this, n"OnVehicleStateChanged");
    this.m_vehicleInfoCallbackID = this.m_chunkBlackboard.RegisterDelayedListenerVariant(this.m_chunkBlackboardDef.ScannerVehicleInfo, this, n"OnVehicleInfoChanged");
    this.OnVehicleNameChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerVehicleName));
    this.OnVehicleManufacturerChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerVehicleManufacturer));
    this.OnVehicleProdYearsChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerVehicleProductionYears));
    this.OnVehicleeDriveLayoutChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerVehicleDriveLayout));
    this.OnVehicleHorsepowerChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerVehicleHorsepower));
    this.OnVehicleMassChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerVehicleMass));
    this.OnVehicleStateChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerVehicleState));
    this.OnVehicleInfoChanged(this.m_chunkBlackboard.GetVariant(this.m_chunkBlackboardDef.ScannerVehicleInfo));
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleName, this.m_vehicleNameCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleManufacturer, this.m_vehicleManufacturerCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleProductionYears, this.m_vehicleProdYearsCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleDriveLayout, this.m_vehicleDriveLayoutCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleHorsepower, this.m_vehicleHorsepowerCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleMass, this.m_vehicleMassCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleState, this.m_vehicleStateCallbackID);
    this.m_chunkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ScannerModules.ScannerVehicleInfo, this.m_vehicleInfoCallbackID);
  }

  protected cb func OnVehicleNameChanged(value: Variant) -> Bool {
    let vehicleNameData: ref<ScannerVehicleName> = FromVariant(value);
    if IsDefined(vehicleNameData) {
      inkTextRef.SetLocalizedTextScript(this.m_vehicleNameText, vehicleNameData.GetDisplayName());
      this.m_isValidVehicleName = true;
    } else {
      this.m_isValidVehicleName = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnVehicleManufacturerChanged(value: Variant) -> Bool {
    let iconRecord: ref<UIIcon_Record>;
    let vehicleManufacturer: ref<ScannerVehicleManufacturer> = FromVariant(value);
    if IsDefined(vehicleManufacturer) {
      iconRecord = TweakDBInterface.GetUIIconRecord(TDBID.Create("UIIcon." + vehicleManufacturer.GetVehicleManufacturer()));
      inkImageRef.SetTexturePart(this.m_vehicleManufacturer, iconRecord.AtlasPartName());
      this.m_isValidVehicleManufacturer = true;
    } else {
      this.m_isValidVehicleManufacturer = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnVehicleProdYearsChanged(value: Variant) -> Bool {
    let vehicleProductionYearsData: ref<ScannerVehicleProdYears> = FromVariant(value);
    if IsDefined(vehicleProductionYearsData) {
      inkTextRef.SetText(this.m_vehicleProdYearsText, vehicleProductionYearsData.GetProdYears());
      this.m_isValidVehicleProdYears = true;
    } else {
      this.m_isValidVehicleProdYears = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnVehicleeDriveLayoutChanged(value: Variant) -> Bool {
    let vehicleVehicleDriveLayoutData: ref<ScannerVehicleDriveLayout> = FromVariant(value);
    if IsDefined(vehicleVehicleDriveLayoutData) {
      inkTextRef.SetLocalizedTextScript(this.m_vehicleDriveLayoutText, vehicleVehicleDriveLayoutData.GetDriveLayout());
      this.m_isValidVehicleDriveLayout = true;
    } else {
      this.m_isValidVehicleDriveLayout = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnVehicleHorsepowerChanged(value: Variant) -> Bool {
    let vehicleHorsepowerData: ref<ScannerVehicleHorsepower> = FromVariant(value);
    if IsDefined(vehicleHorsepowerData) {
      inkTextRef.SetText(this.m_vehicleHorsepowerText, ToString(vehicleHorsepowerData.GetHorsepower()));
      this.m_isValidVehicleHorsepower = true;
    } else {
      this.m_isValidVehicleHorsepower = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnVehicleMassChanged(value: Variant) -> Bool {
    let vehicleMassData: ref<ScannerVehicleMass> = FromVariant(value);
    if IsDefined(vehicleMassData) {
      inkTextRef.SetText(this.m_vehicleMassText, ToString(vehicleMassData.GetMass()));
      this.m_isValidVehicleMass = true;
    } else {
      this.m_isValidVehicleMass = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnVehicleStateChanged(value: Variant) -> Bool {
    let vehicleStateData: ref<ScannerVehicleState> = FromVariant(value);
    if IsDefined(vehicleStateData) {
      inkTextRef.SetLocalizedTextScript(this.m_vehicleStateText, vehicleStateData.GetVehicleState());
      this.m_isValidVehicleState = true;
    } else {
      this.m_isValidVehicleState = false;
    };
    this.UpdateGlobalVisibility();
  }

  protected cb func OnVehicleInfoChanged(value: Variant) -> Bool {
    let vehicleInfoData: ref<ScannerVehicleInfo> = FromVariant(value);
    if IsDefined(vehicleInfoData) {
      inkTextRef.SetLocalizedTextScript(this.m_vehicleInfoText, vehicleInfoData.GetVehicleInfo());
      this.m_isValidVehicleInfo = true;
    } else {
      this.m_isValidVehicleInfo = false;
    };
    this.UpdateGlobalVisibility();
  }

  private final func UpdateGlobalVisibility() -> Void {
    this.GetRootWidget().SetVisible(this.m_isValidVehicleName || this.m_isValidVehicleProdYears || this.m_isValidVehicleDriveLayout || this.m_isValidVehicleHorsepower || this.m_isValidVehicleMass || this.m_isValidVehicleState || this.m_isValidVehicleInfo);
    inkWidgetRef.SetVisible(this.m_vehicleNameHolder, this.m_isValidVehicleName);
    inkWidgetRef.SetVisible(this.m_vehicleProdYearsHolder, this.m_isValidVehicleProdYears);
    inkWidgetRef.SetVisible(this.m_vehicleDriveLayoutHolder, this.m_isValidVehicleDriveLayout);
    inkWidgetRef.SetVisible(this.m_vehicleHorsepowerHolder, this.m_isValidVehicleHorsepower);
    inkWidgetRef.SetVisible(this.m_vehicleMassHolder, this.m_isValidVehicleMass);
    inkWidgetRef.SetVisible(this.m_vehicleStateHolder, this.m_isValidVehicleState);
    inkWidgetRef.SetVisible(this.m_vehicleInfoHolder, this.m_isValidVehicleInfo);
    inkWidgetRef.SetVisible(this.m_vehicleManufacturer, this.m_isValidVehicleManufacturer);
  }
}

public class QuickHackDescriptionGameController extends BaseChunkGameController {

  private edit let m_subHeader: inkTextRef;

  private edit let m_tier: inkTextRef;

  private edit let m_description: inkTextRef;

  private edit let m_recompileTimer: inkTextRef;

  private edit let m_duration: inkTextRef;

  private edit let m_cooldown: inkTextRef;

  private edit let m_uploadTime: inkTextRef;

  private edit let m_memoryCost: inkTextRef;

  private edit let m_memoryRawCost: inkTextRef;

  private edit let m_categoryText: inkTextRef;

  private edit let m_categoryContainer: inkWidgetRef;

  private edit let m_damageWrapper: inkWidgetRef;

  private edit let m_damageLabel: inkTextRef;

  private edit let m_damageValue: inkTextRef;

  private edit let m_healthPercentageLabel: inkTextRef;

  private let m_quickHackDataCallbackID: ref<CallbackHandle>;

  public let m_selectedData: ref<QuickhackData>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    if !IsDefined(this.m_quickHackDataCallbackID) {
      this.m_quickHackDataCallbackID = GameInstance.GetBlackboardSystem(this.GetPlayerControlledObject().GetGame()).Get(GetAllBlackboardDefs().UI_QuickSlotsData).RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_QuickSlotsData.quickHackDataSelected, this, n"OnQuickHackDataChanged");
    };
    this.OnQuickHackDataChanged(GameInstance.GetBlackboardSystem(this.GetPlayerControlledObject().GetGame()).Get(GetAllBlackboardDefs().UI_QuickSlotsData).GetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.quickHackDataSelected));
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_quickHackDataCallbackID) {
      GameInstance.GetBlackboardSystem(this.GetPlayerControlledObject().GetGame()).Get(GetAllBlackboardDefs().UI_QuickSlotsData).UnregisterDelayedListener(GetAllBlackboardDefs().UI_QuickSlotsData.quickHackDataSelected, this.m_quickHackDataCallbackID);
    };
  }

  protected cb func OnQuickHackDataChanged(value: Variant) -> Bool {
    this.m_selectedData = FromVariant(value);
    if IsDefined(this.m_selectedData) {
      inkTextRef.SetLocalizedTextScript(this.m_subHeader, this.m_selectedData.m_title);
      inkTextRef.SetLocalizedTextScript(this.m_description, this.m_selectedData.m_description);
      this.SetupTier();
      this.SetupDuration();
      this.SetupMaxCooldown();
      this.SetupUploadTime();
      this.SetupMemotyCost();
      this.SetupCategory();
      this.SetupDamage();
    };
  }

  private final func SetupTier() -> Void {
    let value: Int32 = this.m_selectedData.m_quality;
    let textParams: ref<inkTextParams> = new inkTextParams();
    textParams.AddNumber("VALUE", value);
    (inkWidgetRef.Get(this.m_tier) as inkText).SetLocalizedTextScript("LocKey#40895", textParams);
  }

  private final func SetupDuration() -> Void {
    let value: Float = this.m_selectedData.m_duration;
    let textParams: ref<inkTextParams> = new inkTextParams();
    textParams.AddNumber("VALUE", value);
    textParams.AddLocalizedString("SEC", "LocKey#40730");
    (inkWidgetRef.Get(this.m_duration) as inkText).SetLocalizedTextScript("LocKey#40736", textParams);
    if value == 0.00 {
      inkWidgetRef.SetState(this.m_duration, n"Locked");
    } else {
      inkWidgetRef.SetState(this.m_duration, n"Default");
    };
  }

  private final func SetupMaxCooldown() -> Void {
    let value: Float = this.m_selectedData.m_cooldown;
    let textParams: ref<inkTextParams> = new inkTextParams();
    textParams.AddNumber("VALUE", value);
    textParams.AddLocalizedString("SEC", "LocKey#40730");
    (inkWidgetRef.Get(this.m_cooldown) as inkText).SetLocalizedTextScript("LocKey#40729", textParams);
    if value == 0.00 {
      inkWidgetRef.SetState(this.m_cooldown, n"Locked");
    } else {
      inkWidgetRef.SetState(this.m_cooldown, n"Default");
    };
  }

  private final func SetupUploadTime() -> Void {
    let value: Float = this.m_selectedData.m_uploadTime;
    let textParams: ref<inkTextParams> = new inkTextParams();
    textParams.AddNumber("VALUE", value);
    textParams.AddLocalizedString("SEC", "LocKey#40730");
    (inkWidgetRef.Get(this.m_uploadTime) as inkText).SetLocalizedTextScript("LocKey#40737", textParams);
    if value == 0.00 {
      inkWidgetRef.SetState(this.m_uploadTime, n"Locked");
    } else {
      inkWidgetRef.SetState(this.m_uploadTime, n"Default");
    };
  }

  private final func SetupMemotyCost() -> Void {
    let textParams: ref<inkTextParams>;
    let value: Int32;
    inkTextRef.SetText(this.m_memoryCost, IntToString(this.m_selectedData.m_cost));
    value = this.m_selectedData.m_costRaw;
    textParams = new inkTextParams();
    textParams.AddNumber("VALUE", value);
    (inkWidgetRef.Get(this.m_memoryRawCost) as inkText).SetLocalizedTextScript("LocKey#40804", textParams);
  }

  private final func SetupCategory() -> Void {
    if IsDefined(this.m_selectedData.m_category) && NotEquals(this.m_selectedData.m_category.EnumName(), n"NotAHack") {
      inkTextRef.SetText(this.m_categoryText, this.m_selectedData.m_category.LocalizedDescription());
      inkWidgetRef.SetVisible(this.m_categoryContainer, true);
    } else {
      inkWidgetRef.SetVisible(this.m_categoryContainer, false);
    };
  }

  private final func IsDamageStat(targetStat: gamedataStatType, valueStat: gamedataStatType) -> Bool {
    if Equals(targetStat, gamedataStatType.Invalid) {
      switch valueStat {
        case gamedataStatType.ThermalDamage:
        case gamedataStatType.ElectricDamage:
        case gamedataStatType.ChemicalDamage:
        case gamedataStatType.PhysicalDamage:
        case gamedataStatType.BaseDamage:
          return true;
        default:
          return false;
      };
    } else {
      return Equals(targetStat, gamedataStatType.Health);
    };
    return false;
  }

  private final func SetupDamage() -> Void {
    let effect: ref<DamageEffectUIEntry>;
    let effects: array<ref<DamageEffectUIEntry>>;
    let i: Int32;
    let isHealthPercentageStat: Bool;
    let j: Int32;
    let totalEffects: array<ref<DamageEffectUIEntry>>;
    let valueToDisplay: String;
    inkWidgetRef.SetVisible(this.m_damageWrapper, false);
    i = 0;
    while i < ArraySize(this.m_selectedData.m_actionCompletionEffects) {
      if !InventoryDataManagerV2.ProcessQuickhackEffects(this.GetPlayerControlledObject(), this.m_selectedData.m_actionCompletionEffects[i].StatusEffect(), effects) {
      } else {
        j = 0;
        while j < ArraySize(effects) {
          ArrayPush(totalEffects, effects[j]);
          j += 1;
        };
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(totalEffects) {
      effect = totalEffects[i];
      if !this.IsDamageStat(effect.targetStat, effect.valueStat) {
      } else {
        isHealthPercentageStat = Equals(effect.targetStat, gamedataStatType.Health);
        inkWidgetRef.SetVisible(this.m_healthPercentageLabel, isHealthPercentageStat);
        if isHealthPercentageStat {
          valueToDisplay = "-";
        };
        valueToDisplay += IntToString(CeilF(effect.valueToDisplay));
        if isHealthPercentageStat {
          valueToDisplay += "%";
        };
        if effect.isContinuous {
          valueToDisplay += "/" + GetLocalizedText("UI-Quickhacks-Seconds");
        };
        inkTextRef.SetText(this.m_damageValue, valueToDisplay);
        inkTextRef.SetText(this.m_damageLabel, UILocalizationHelper.GetStatNameLockey(RPGManager.GetStatRecord(effect.valueStat)));
        inkWidgetRef.SetVisible(this.m_damageWrapper, true);
        goto 1134;
      };
      i += 1;
    };
  }
}
