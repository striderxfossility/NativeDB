
public class PlayerStateMachineDef extends BlackboardDefinition {

  public let Locomotion: BlackboardID_Int;

  public let LocomotionDetailed: BlackboardID_Int;

  public let HighLevel: BlackboardID_Int;

  public let UpperBody: BlackboardID_Int;

  public let TimeDilation: BlackboardID_Int;

  public let Weapon: BlackboardID_Int;

  public let Melee: BlackboardID_Int;

  public let UI: BlackboardID_Int;

  public let Crosshair: BlackboardID_Int;

  public let Reaction: BlackboardID_Int;

  public let Zones: BlackboardID_Int;

  public let SecurityZoneData: BlackboardID_Variant;

  public let Vision: BlackboardID_Int;

  public let VisionDebug: BlackboardID_Int;

  public let SceneTier: BlackboardID_Int;

  public let CombatGadget: BlackboardID_Int;

  public let LastCombatGadgetUsed: BlackboardID_Variant;

  public let Consumable: BlackboardID_Int;

  public let Vehicle: BlackboardID_Int;

  public let MountedToCombatVehicle: BlackboardID_Bool;

  public let MountedToVehicle: BlackboardID_Bool;

  public let ZoomLevel: BlackboardID_Float;

  public let MaxZoomLevel: BlackboardID_Int;

  public let ToggleFireMode: BlackboardID_Bool;

  public let SwitchWeapon: BlackboardID_Bool;

  public let IsDoorInteractionActive: BlackboardID_Bool;

  public let IsInteractingWithDevice: BlackboardID_Bool;

  public let IsForceOpeningDoor: BlackboardID_Bool;

  public let IsControllingDevice: BlackboardID_Bool;

  public let IsUIZoomDevice: BlackboardID_Bool;

  public let UseUnarmed: BlackboardID_Bool;

  public let Berserk: BlackboardID_Int;

  public let ActiveCyberware: BlackboardID_Int;

  public let Whip: BlackboardID_Int;

  public let DEBUG_SilencedWeapon: BlackboardID_Bool;

  public let LeftHandCyberware: BlackboardID_Int;

  public let UseLeftHand: BlackboardID_Bool;

  public let MeleeWeapon: BlackboardID_Int;

  public let Carrying: BlackboardID_Bool;

  public let CarryingDisposal: BlackboardID_Bool;

  public let CurrentElevator: BlackboardID_Variant;

  public let IsPlayerInsideElevator: BlackboardID_Bool;

  public let IsPlayerInsideMovingElevator: BlackboardID_Bool;

  public let Combat: BlackboardID_Int;

  public let Stamina: BlackboardID_Int;

  public let Vitals: BlackboardID_Int;

  public let Takedown: BlackboardID_Int;

  public let Fall: BlackboardID_Int;

  public let Landing: BlackboardID_Int;

  public let UsingCover: BlackboardID_Bool;

  public let IsInMinigame: BlackboardID_Bool;

  public let IsUploadingQuickHack: BlackboardID_Int;

  public let EntityIDTargetingPlayer: BlackboardID_EntityID;

  public let Swimming: BlackboardID_Int;

  public let BodyCarrying: BlackboardID_Int;

  public let BodyCarryingLocomotion: BlackboardID_Int;

  public let BodyDisposalDetailed: BlackboardID_Int;

  public let DisplayDeathMenu: BlackboardID_Bool;

  public let OverrideQuickHackPanelDilation: BlackboardID_Bool;

  public let NanoWireLaunchMode: BlackboardID_Int;

  public let IsMovingHorizontally: BlackboardID_Bool;

  public let IsMovingVertically: BlackboardID_Bool;

  public let ActionRestriction: BlackboardID_Variant;

  public let MeleeLeap: BlackboardID_Bool;

  public let IsInWorkspot: BlackboardID_Int;

  public let QuestForceShoot: BlackboardID_Bool;

  public let SceneAimForced: BlackboardID_Bool;

  public let SceneSafeForced: BlackboardID_Bool;

  public let SceneWeaponLoweringSpeedOverride: BlackboardID_Float;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }
}

public class PlayerPerkDataDef extends BlackboardDefinition {

  public let WoundedInstigated: BlackboardID_Uint;

  public let DismembermentInstigated: BlackboardID_Uint;

  public let EntityNoticedPlayer: BlackboardID_Uint;

  public let CombatStateTime: BlackboardID_Float;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class PlayerQuickHackDataDef extends BlackboardDefinition {

  public let CachedQuickHackList: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class PuppetDef extends BlackboardDefinition {

  public let IsCrowd: BlackboardID_Bool;

  public let HideNameplate: BlackboardID_Bool;

  public let ForceFriendlyCarry: BlackboardID_Bool;

  public let ForcedCarryStyle: BlackboardID_Int;

  public let HasCPOMissionData: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }
}

public class HackingDataDef extends BlackboardDefinition {

  public let SpreadMap: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }

  public final static func AddItemToSpreadMap(player: wref<PlayerPuppet>, key: wref<InteractionBase_Record>, count: Int32, range: Float) -> Bool {
    let hackingData: ref<IBlackboard>;
    let i: Int32;
    let spreadItem: SpreadMapItem;
    let spreadMap: array<SpreadMapItem>;
    if !IsDefined(player) || !IsDefined(key) {
      return false;
    };
    hackingData = player.GetHackingDataBlackboard();
    if !IsDefined(hackingData) {
      return false;
    };
    spreadMap = FromVariant(hackingData.GetVariant(GetAllBlackboardDefs().HackingData.SpreadMap));
    i = 0;
    while i < ArraySize(spreadMap) {
      if spreadMap[i].key == key {
        spreadMap[i].count = count;
        spreadMap[i].range = range;
        hackingData.SetVariant(GetAllBlackboardDefs().HackingData.SpreadMap, ToVariant(spreadMap));
        return true;
      };
      i += 1;
    };
    spreadItem.key = key;
    spreadItem.count = count;
    spreadItem.range = range;
    ArrayPush(spreadMap, spreadItem);
    hackingData.SetVariant(GetAllBlackboardDefs().HackingData.SpreadMap, ToVariant(spreadMap));
    return true;
  }

  public final static func GetValuesFromSpreadMap(player: wref<PlayerPuppet>, key: wref<InteractionBase_Record>, out count: Int32, out range: Float) -> Bool {
    let hackingData: ref<IBlackboard>;
    let i: Int32;
    let spreadMap: array<SpreadMapItem>;
    if !IsDefined(player) || !IsDefined(key) {
      return false;
    };
    hackingData = player.GetHackingDataBlackboard();
    if !IsDefined(hackingData) {
      return false;
    };
    spreadMap = FromVariant(hackingData.GetVariant(GetAllBlackboardDefs().HackingData.SpreadMap));
    i = 0;
    while i < ArraySize(spreadMap) {
      if spreadMap[i].key == key {
        count = spreadMap[i].count;
        range = spreadMap[i].range;
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func DecrementCountFromSpreadMap(player: wref<PlayerPuppet>, key: wref<InteractionBase_Record>) -> Bool {
    let hackingData: ref<IBlackboard>;
    let i: Int32;
    let spreadMap: array<SpreadMapItem>;
    if !IsDefined(player) || !IsDefined(key) {
      return false;
    };
    hackingData = player.GetHackingDataBlackboard();
    if !IsDefined(hackingData) {
      return false;
    };
    spreadMap = FromVariant(hackingData.GetVariant(GetAllBlackboardDefs().HackingData.SpreadMap));
    i = 0;
    while i < ArraySize(spreadMap) {
      if spreadMap[i].key == key {
        spreadMap[i].count = spreadMap[i].count - 1;
        hackingData.SetVariant(GetAllBlackboardDefs().HackingData.SpreadMap, ToVariant(spreadMap));
        if spreadMap[i].count <= 0 {
          return false;
        };
        return true;
      };
      i += 1;
    };
    return false;
  }
}

public class HackingMinigameDef extends BlackboardDefinition {

  public let MinigameDefaults: BlackboardID_Variant;

  public let NextMinigameData: BlackboardID_Variant;

  public let SkipSummaryScreen: BlackboardID_Bool;

  public let PlayerPrograms: BlackboardID_Variant;

  public let ActivePrograms: BlackboardID_Variant;

  public let ActiveTraps: BlackboardID_Variant;

  public let State: BlackboardID_Int;

  public let TimerLeftPercent: BlackboardID_Float;

  public let Entity: BlackboardID_Variant;

  public let IsJournalTarget: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_PlayerStatsDef extends BlackboardDefinition {

  public let MaxHealth: BlackboardID_Int;

  public let CurrentHealth: BlackboardID_Int;

  public let PhysicalResistance: BlackboardID_Int;

  public let ThermalResistance: BlackboardID_Int;

  public let EnergyResistance: BlackboardID_Int;

  public let ChemicalResistance: BlackboardID_Int;

  public let Level: BlackboardID_Int;

  public let CurrentXP: BlackboardID_Int;

  public let StreetCredLevel: BlackboardID_Int;

  public let StreetCredPoints: BlackboardID_Int;

  public let Attributes: BlackboardID_Variant;

  public let DevelopmentPoints: BlackboardID_Variant;

  public let Proficiency: BlackboardID_Variant;

  public let Perks: BlackboardID_Variant;

  public let ModifiedPerkArea: BlackboardID_Variant;

  public let weightMax: BlackboardID_Int;

  public let currentInventoryWeight: BlackboardID_Float;

  public let isReplacer: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class PuppetStateDef extends BlackboardDefinition {

  public let HighLevel: BlackboardID_Int;

  public let UpperBody: BlackboardID_Int;

  public let BehaviorState: BlackboardID_Int;

  public let PhaseState: BlackboardID_Int;

  public let Stance: BlackboardID_Int;

  public let HitReactionMode: BlackboardID_Int;

  public let DefenseMode: BlackboardID_Int;

  public let LocomotionMode: BlackboardID_Int;

  public let WeakSpots: BlackboardID_Int;

  public let ReactionBehavior: BlackboardID_Int;

  public let ForceRagdollOnDeath: BlackboardID_Bool;

  public let InExclusiveAction: BlackboardID_Bool;

  public let SlotAnimationInProgress: BlackboardID_Bool;

  public let InPendingBehavior: BlackboardID_Bool;

  public let HasCalledReinforcements: BlackboardID_Bool;

  public let IsBodyDisposed: BlackboardID_Bool;

  public let DetectionPercentage: BlackboardID_Float;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }
}

public class PuppetReactionDef extends BlackboardDefinition {

  public let exitReactionFlag: BlackboardID_Bool;

  public let blockReactionFlag: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }
}

public class AISquadBlackBoardDef extends BlackboardDefinition {

  public let BarkPlayed: BlackboardID_Bool;

  public let LowHealthBarkPlayed: BlackboardID_Bool;

  public let BarkPlayedTimeStamp: BlackboardID_Float;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class FollowNPCDef extends BlackboardDefinition {

  public let Position: BlackboardID_Vector4;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }
}

public class DeviceDebugDef extends BlackboardDefinition {

  public let CurrentlyDebuggedDevice: BlackboardID_Name;

  public let DebuggedEntityIDAsString: BlackboardID_String;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class EffectSharedDataDef extends BlackboardDefinition {

  public let attackStatModList: BlackboardID_Variant;

  public let box: BlackboardID_Vector4;

  public let charge: BlackboardID_Float;

  public let duration: BlackboardID_Float;

  public let hitCooldown: BlackboardID_Float;

  public let effectName: BlackboardID_String;

  public let entity: BlackboardID_Entity;

  public let forward: BlackboardID_Vector4;

  public let fxPackage: BlackboardID_Variant;

  public let attackData: BlackboardID_Variant;

  public let infiniteDuration: BlackboardID_Bool;

  public let playerOwnedWeapon: BlackboardID_Bool;

  public let position: BlackboardID_Vector4;

  public let muzzlePosition: BlackboardID_Vector4;

  public let projectileHitEvent: BlackboardID_Variant;

  public let radius: BlackboardID_Float;

  public let range: BlackboardID_Float;

  public let renderMaterialOverride: BlackboardID_Bool;

  public let clearMaterialOverlayOnDetach: BlackboardID_Bool;

  public let rotation: BlackboardID_Quat;

  public let minRayAngleDiff: BlackboardID_Float;

  public let statType: BlackboardID_Int;

  public let stimuliEvent: BlackboardID_Variant;

  public let stimuliRaycastTest: BlackboardID_Bool;

  public let stimType: BlackboardID_Int;

  public let value: BlackboardID_Float;

  public let flags: BlackboardID_Variant;

  public let attack: BlackboardID_Variant;

  public let attackId: BlackboardID_Variant;

  public let attackNumber: BlackboardID_Int;

  public let impactOrientationSlot: BlackboardID_Name;

  public let statusEffect: BlackboardID_Variant;

  public let angle: BlackboardID_Float;

  public let fallback_weaponPierce: BlackboardID_Bool;

  public let fallback_weaponPierceChargeLevel: BlackboardID_Float;

  public let raycastEnd: BlackboardID_Vector4;

  public let maxPathLength: BlackboardID_Float;

  public let effectorRecordName: BlackboardID_String;

  public let targets: BlackboardID_Variant;

  public let highlightType: BlackboardID_Int;

  public let outlineType: BlackboardID_Int;

  public let highlightPriority: BlackboardID_Int;

  public let fxResource: BlackboardID_Variant;

  public let dotCycleDuration: BlackboardID_Float;

  public let dotLastApplicationTime: BlackboardID_Float;

  public let enable: BlackboardID_Bool;

  public let slotName: BlackboardID_Name;

  public let targetComponent: BlackboardID_Variant;

  public let meleeCleave: BlackboardID_Bool;

  public let highlightedTargets: BlackboardID_Variant;

  public let forceVisionAppearanceData: BlackboardID_Variant;

  public let tickRateOverride: BlackboardID_Float;

  public let debugBool: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }
}

public class UI_SystemDef extends BlackboardDefinition {

  public let IsInMenu: BlackboardID_Bool;

  public let CircularBlurEnabled: BlackboardID_Bool;

  public let CircularBlurBlendTime: BlackboardID_Float;

  public let TrackedMappin: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class LocalPlayerDef extends BlackboardDefinition {

  public let InsideVehicleForbiddenAreasCount: BlackboardID_Int;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UIGameDataDef extends BlackboardDefinition {

  public let InteractionData: BlackboardID_Variant;

  public let ShowDialogLine: BlackboardID_Variant;

  public let HideDialogLine: BlackboardID_Variant;

  public let HideDialogLineByData: BlackboardID_Variant;

  public let ShowSceneComment: BlackboardID_String;

  public let HideSceneComment: BlackboardID_Bool;

  public let ShowSubtitlesBackground: BlackboardID_Bool;

  public let Popup_IsModal: BlackboardID_Bool;

  public let Popup_IsShown: BlackboardID_Bool;

  public let Popup_Data: BlackboardID_Variant;

  public let Popup_Settings: BlackboardID_Variant;

  public let Controller_Disconnected: BlackboardID_Bool;

  public let ActivityLog: BlackboardID_Variant;

  public let RightWeaponRecordID: BlackboardID_Variant;

  public let LeftWeaponRecordID: BlackboardID_Variant;

  public let UIVendorContextRequest: BlackboardID_Bool;

  public let UIjailbreakData: BlackboardID_Variant;

  public let QuestTimerInitialDuration: BlackboardID_Float;

  public let QuestTimerCurrentDuration: BlackboardID_Float;

  public let Tutorial_EnableHighlight: BlackboardID_Bool;

  public let Tutorial_EntityRefToHighlight: BlackboardID_Variant;

  public let WeaponSway: BlackboardID_Vector2;

  public let NotificationJournalHash: BlackboardID_Int;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UIInteractionsDef extends BlackboardDefinition {

  public let InteractionChoiceHub: BlackboardID_Variant;

  public let DialogChoiceHubs: BlackboardID_Variant;

  public let LootData: BlackboardID_Variant;

  public let ContactsData: BlackboardID_Variant;

  public let ActiveChoiceHubID: BlackboardID_Int;

  public let SelectedIndex: BlackboardID_Int;

  public let ActiveInteractions: BlackboardID_Variant;

  public let InteractionSkillCheckHub: BlackboardID_Variant;

  public let NameplateOwnerID: BlackboardID_EntityID;

  public let VisualizersInfo: BlackboardID_Variant;

  public let ShouldHideClampedMappins: BlackboardID_Bool;

  public let LastAttemptedChoice: BlackboardID_Variant;

  public let LookAtTargetVisualizerID: BlackboardID_Int;

  public let HasScrollableInteraction: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class DebugDataDef extends BlackboardDefinition {

  public let WeaponSpread_EvenDistributionRowCount: BlackboardID_Int;

  public let WeaponSpread_ProjectilesPerShot: BlackboardID_Int;

  public let WeaponSpread_UseCircularSpread: BlackboardID_Bool;

  public let WeaponSpread_UseEvenDistribution: BlackboardID_Bool;

  public let Vehicle_BlockSwitchSeats: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_ActiveVehicleDataDef extends BlackboardDefinition {

  public let VehPlayerStateData: BlackboardID_Variant;

  public let IsPlayerMounted: BlackboardID_Bool;

  public let IsTPPCameraOn: BlackboardID_Bool;

  public let PositionInRace: BlackboardID_Int;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UIWorldBoundariesDef extends BlackboardDefinition {

  public let IsPlayerCloseToBoundary: BlackboardID_Bool;

  public let IsPlayerGoingDeeper: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class VehicleDef extends BlackboardDefinition {

  public let BikeTilt: BlackboardID_Float;

  public let SpeedValue: BlackboardID_Float;

  public let GearValue: BlackboardID_Int;

  public let RPMValue: BlackboardID_Float;

  public let RPMMax: BlackboardID_Float;

  public let SuspensionTransversalForce: BlackboardID_Float;

  public let SuspensionLongitudinalForce: BlackboardID_Float;

  public let IsAutopilotOn: BlackboardID_Bool;

  public let DeclutchTimer: BlackboardID_Float;

  public let HandlingPenalty: BlackboardID_Float;

  public let LightMode: BlackboardID_Int;

  public let VehicleState: BlackboardID_Int;

  public let VehicleReady: BlackboardID_Bool;

  public let VehRadioState: BlackboardID_Bool;

  public let VehRadioStationName: BlackboardID_Name;

  public let IsCrowd: BlackboardID_Bool;

  public let IsUIActive: BlackboardID_Bool;

  public let GameTime: BlackboardID_String;

  public let Collision: BlackboardID_Bool;

  public let DamageState: BlackboardID_Int;

  public let MeanSlipRatio: BlackboardID_Float;

  public let IsHandbraking: BlackboardID_Int;

  public let EngineTemp: BlackboardID_Float;

  public let IsInWater: BlackboardID_Bool;

  public let RaceTimer: BlackboardID_String;

  public let IsTargetingFriendly: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }
}

public class VehicleSummonDataDef extends BlackboardDefinition {

  public let GarageState: BlackboardID_Uint;

  public let UnlockedVehiclesCount: BlackboardID_Uint;

  public let SummonState: BlackboardID_Uint;

  public let SummonedVehicleEntityID: BlackboardID_EntityID;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class AIFollowSlotDef extends BlackboardDefinition {

  public let slotID: BlackboardID_Int;

  public let slotTransform: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }
}

public class WeaponDataDef extends BlackboardDefinition {

  public let Charge: BlackboardID_Float;

  public let OverheatPercentage: BlackboardID_Float;

  public let IsInForcedOverheatCooldown: BlackboardID_Bool;

  public let ChargeStep: BlackboardID_Variant;

  public let TriggerMode: BlackboardID_Variant;

  public let MagazineAmmoCapacity: BlackboardID_Uint;

  public let MagazineAmmoCount: BlackboardID_Uint;

  public let MagazineAmmoID: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }
}

public class MinesDataDef extends BlackboardDefinition {

  public let CurrentNormal: BlackboardID_Vector4;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class BraindanceBlackboardDef extends BlackboardDefinition {

  public let activeBraindanceVisionMode: BlackboardID_Int;

  public let lastBraindanceVisionMode: BlackboardID_Int;

  public let Progress: BlackboardID_Float;

  public let SectionTime: BlackboardID_Float;

  public let Clue: BlackboardID_Variant;

  public let IsActive: BlackboardID_Bool;

  public let EnableExit: BlackboardID_Bool;

  public let IsFPP: BlackboardID_Bool;

  public let PlaybackSpeed: BlackboardID_Variant;

  public let PlaybackDirection: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_EquipmentDataDef extends BlackboardDefinition {

  public let EquipmentData: BlackboardID_Variant;

  public let UIjailbreakData: BlackboardID_Variant;

  public let ammoLooted: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_PlayerBioMonitorDef extends BlackboardDefinition {

  public let PlayerStatsInfo: BlackboardID_Variant;

  public let BuffsList: BlackboardID_Variant;

  public let DebuffsList: BlackboardID_Variant;

  public let Cooldowns: BlackboardID_Variant;

  public let AdrenalineBar: BlackboardID_Float;

  public let CurrentNetrunnerCharges: BlackboardID_Int;

  public let NetworkChargesCapacity: BlackboardID_Int;

  public let NetworkName: BlackboardID_Name;

  public let MemoryPercent: BlackboardID_Float;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class FastTRavelSystemDef extends BlackboardDefinition {

  public let DestinationPoint: BlackboardID_Variant;

  public let StartingPoint: BlackboardID_Variant;

  public let FastTravelLoadingScreenFinished: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class DeviceBaseBlackboardDef extends BlackboardDefinition {

  public let ActionWidgetsData: BlackboardID_Variant;

  public let DeviceWidgetsData: BlackboardID_Variant;

  public let UIupdate: BlackboardID_Bool;

  public let BreadCrumbElement: BlackboardID_Variant;

  public let GlitchData: BlackboardID_Variant;

  public let UI_InteractivityBlocked: BlackboardID_Bool;

  public let IsInvestigated: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }
}

public class NetworkBlackboardDef extends BlackboardDefinition {

  public let MinigameDef: BlackboardID_Variant;

  public let NetworkName: BlackboardID_String;

  public let NetworkTDBID: BlackboardID_Variant;

  public let DevicesCount: BlackboardID_Int;

  public let DeviceID: BlackboardID_EntityID;

  public let OfficerBreach: BlackboardID_Bool;

  public let SuicideBreach: BlackboardID_Bool;

  public let RemoteBreach: BlackboardID_Bool;

  public let ItemBreach: BlackboardID_Bool;

  public let Attempt: BlackboardID_Int;

  public let SelectedMinigameDef: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class StorageBlackboardDef extends BlackboardDefinition {

  public let StorageData: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class MenuEventBlackboardDef extends BlackboardDefinition {

  public let MenuEventToTrigger: BlackboardID_Name;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_ComDeviceDef extends BlackboardDefinition {

  public let comDeviceSetStatusText: BlackboardID_Name;

  public let openMessageRequest: BlackboardID_Uint;

  public let closeMessageRequest: BlackboardID_Int;

  public let showingMessage: BlackboardID_Int;

  public let PhoneCallInformation: BlackboardID_Variant;

  public let PhoneStyle_PlacidePhone: BlackboardID_Bool;

  public let PhoneStyle_VideoCallInterupt: BlackboardID_Bool;

  public let PhoneStyle_Minimized: BlackboardID_Bool;

  public let isDisplayingMessage: BlackboardID_Bool;

  public let ContactsActive: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_ScannerDef extends BlackboardDefinition {

  public let Scannables: BlackboardID_Variant;

  public let CurrentProgress: BlackboardID_Float;

  public let CurrentState: BlackboardID_Variant;

  public let ProgressBarText: BlackboardID_String;

  public let ScannedObject: BlackboardID_EntityID;

  public let ScannerMode: BlackboardID_Variant;

  public let scannerTooltip: BlackboardID_Int;

  public let scannerData: BlackboardID_Variant;

  public let scannerObjectDistance: BlackboardID_Float;

  public let scannerObjectStats: BlackboardID_Variant;

  public let scannerQuickHackActionId: BlackboardID_Int;

  public let scannerQuickHackActionStarted: BlackboardID_Bool;

  public let scannerQuickHackTime: BlackboardID_Float;

  public let exclusiveFocusActive: BlackboardID_Bool;

  public let LastTaggedTarget: BlackboardID_Variant;

  public let skillCheckInfo: BlackboardID_Variant;

  public let ShowHudHintMessege: BlackboardID_Bool;

  public let HudHintMessegeContent: BlackboardID_String;

  public let UIVisible: BlackboardID_Bool;

  public let ScannerLookAt: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_ScannerModulesDef extends BlackboardDefinition {

  public let ScannerName: BlackboardID_Variant;

  public let ScannerHealth: BlackboardID_Variant;

  public let ScannerLevel: BlackboardID_Variant;

  public let ScannerAuthorization: BlackboardID_Variant;

  public let ScannerRarity: BlackboardID_Variant;

  public let ScannerArchetype: BlackboardID_Variant;

  public let ScannerFaction: BlackboardID_Variant;

  public let ScannerWeaponBasic: BlackboardID_Variant;

  public let ScannerWeaponDetailed: BlackboardID_Variant;

  public let ScannerVulnerabilities: BlackboardID_Variant;

  public let ScannerSquadInfo: BlackboardID_Variant;

  public let ScannerResistances: BlackboardID_Variant;

  public let ScannerAbilities: BlackboardID_Variant;

  public let ScannerAttitude: BlackboardID_Variant;

  public let ScannerBountySystem: BlackboardID_Variant;

  public let ScannerDeviceStatus: BlackboardID_Variant;

  public let ScannerNetworkLevel: BlackboardID_Variant;

  public let ScannerNetworkStatus: BlackboardID_Variant;

  public let ScannerConnections: BlackboardID_Variant;

  public let ScannerDescription: BlackboardID_Variant;

  public let ScannerSkillChecks: BlackboardID_Variant;

  public let ScannerVehicleName: BlackboardID_Variant;

  public let ScannerVehicleManufacturer: BlackboardID_Variant;

  public let ScannerVehicleProductionYears: BlackboardID_Variant;

  public let ScannerVehicleDriveLayout: BlackboardID_Variant;

  public let ScannerVehicleHorsepower: BlackboardID_Variant;

  public let ScannerVehicleMass: BlackboardID_Variant;

  public let ScannerVehicleState: BlackboardID_Variant;

  public let ScannerVehicleInfo: BlackboardID_Variant;

  public let ScannerQuickHackDescription: BlackboardID_Variant;

  public let ObjectType: BlackboardID_Int;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_WantedBarDef extends BlackboardDefinition {

  public let CurrentBounty: BlackboardID_Int;

  public let CurrentWantedLevel: BlackboardID_Int;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class HUDManagerDef extends BlackboardDefinition {

  public let ShowHudHintMessege: BlackboardID_Bool;

  public let HudHintMessegeContent: BlackboardID_String;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_HUDProgressBarDef extends BlackboardDefinition {

  public let TimerID: BlackboardID_Variant;

  public let Header: BlackboardID_String;

  public let Active: BlackboardID_Bool;

  public let Progress: BlackboardID_Float;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_HUDSignalProgressBarDef extends BlackboardDefinition {

  public let TimerID: BlackboardID_Variant;

  public let State: BlackboardID_Uint;

  public let Progress: BlackboardID_Float;

  public let SignalStrength: BlackboardID_Float;

  public let IsInRange: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_HotkeysDef extends BlackboardDefinition {

  public let ModifiedHotkey: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_NPCNextToTheCrosshairDef extends BlackboardDefinition {

  public let NameplateData: BlackboardID_Variant;

  public let BuffsList: BlackboardID_Variant;

  public let DebuffsList: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_NameplateDataDef extends BlackboardDefinition {

  public let EntityID: BlackboardID_Variant;

  public let IsVisible: BlackboardID_Bool;

  public let HeightOffset: BlackboardID_Float;

  public let DamageProjection: BlackboardID_Int;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_DamageInfoDef extends BlackboardDefinition {

  public let DamageList: BlackboardID_Variant;

  public let KillList: BlackboardID_Variant;

  public let DigitsMode: BlackboardID_Variant;

  public let DigitsInterpolationOn: BlackboardID_Bool;

  public let DigitsStickingMode: BlackboardID_Variant;

  public let HitIndicatorEnabled: BlackboardID_Bool;

  public let DmgIndicatorMode: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_InterfaceOptionsDef extends BlackboardDefinition {

  public let CrowdsOnMinimap: BlackboardID_Bool;

  public let ObjectMarkersEnabled: BlackboardID_Bool;

  public let NPCNamesEnabled: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class VendorRegisterBlackBoardDef extends BlackboardDefinition {

  public let vendors: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_CompassInfoDef extends BlackboardDefinition {

  public let NorthOffset: BlackboardID_Float;

  public let SouthOffset: BlackboardID_Float;

  public let EastOffset: BlackboardID_Float;

  public let WestOffset: BlackboardID_Float;

  public let Pins: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_ActiveWeaponDataDef extends BlackboardDefinition {

  public let WeaponRecordID: BlackboardID_Variant;

  public let BulletSpread: BlackboardID_Vector2;

  public let SmartGunParams: BlackboardID_Variant;

  public let TargetHitEvent: BlackboardID_Variant;

  public let ShootEvent: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_TargetingInfoDef extends BlackboardDefinition {

  public let CurrentVisibleTarget: BlackboardID_EntityID;

  public let VisibleTargetDistance: BlackboardID_Float;

  public let VisibleTargetAttitude: BlackboardID_Int;

  public let CurrentObstructedTarget: BlackboardID_EntityID;

  public let ObstructedTargetDistance: BlackboardID_Float;

  public let ObstructedTargetAttitude: BlackboardID_Int;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_QuickSlotsDataDef extends BlackboardDefinition {

  public let UIRadialContextRequest: BlackboardID_Bool;

  public let UIRadialContextRightStickAngle: BlackboardID_Float;

  public let leftStick: BlackboardID_Vector4;

  public let DPadCommand: BlackboardID_Variant;

  public let KeyboardCommand: BlackboardID_Variant;

  public let WheelInteractionStarted: BlackboardID_Variant;

  public let WheelInteractionEnded: BlackboardID_Variant;

  public let CyberwareAssignmentComplete: BlackboardID_Bool;

  public let WheelAssignmentComplete: BlackboardID_Bool;

  public let quickSlotsStructure: BlackboardID_Variant;

  public let activeQuickSlotItem: BlackboardID_Variant;

  public let quickSlotsActiveWeaponIndex: BlackboardID_Int;

  public let quickhackPanelOpen: BlackboardID_Bool;

  public let quickHackDescritpionVisible: BlackboardID_Bool;

  public let quickHackDataSelected: BlackboardID_Variant;

  public let dpadHintRefresh: BlackboardID_Bool;

  public let containerConsumable: BlackboardID_Variant;

  public let consumableBeingUsed: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_VisionModeDef extends BlackboardDefinition {

  public let isEnabled: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class CustomCentaurBlackboardDef extends CustomBlackboardDef {

  public let ShieldState: BlackboardID_Int;

  public let WeakSpotHitTimeStamp: BlackboardID_Float;

  public let ShieldTarget: BlackboardID_EntityID;

  public let WoundedStateHPThreshold: BlackboardID_Float;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }
}

public class UI_MapDef extends BlackboardDefinition {

  public let currentLocation: BlackboardID_String;

  public let currentLocationEnumName: BlackboardID_String;

  public let newLocationDiscovered: BlackboardID_Bool;

  public let currentState: BlackboardID_String;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_CustomQuestNotificationDef extends BlackboardDefinition {

  public let data: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_HudTooltipDef extends BlackboardDefinition {

  public let ItemId: BlackboardID_Variant;

  public let ShowTooltip: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_HudButtonHelpDef extends BlackboardDefinition {

  public let button1_Text: BlackboardID_String;

  public let button1_Icon: BlackboardID_Name;

  public let button2_Text: BlackboardID_String;

  public let button2_Icon: BlackboardID_Name;

  public let button3_Text: BlackboardID_String;

  public let button3_Icon: BlackboardID_Name;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_NotificationsDef extends BlackboardDefinition {

  public let WarningMessage: BlackboardID_Variant;

  public let OnscreenMessage: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_CpoCharacterSelectionDef extends BlackboardDefinition {

  public let SelectionMenuVisible: BlackboardID_Bool;

  public let CharacterRecordId: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_CrosshairDef extends BlackboardDefinition {

  public let EnemyNeutralized: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class AIShootingDataDef extends AIBlackboardDef {

  public let shootingPatternPackage: BlackboardID_Variant;

  public let shootingPattern: BlackboardID_Variant;

  public let patternList: BlackboardID_Variant;

  public let rightArmLookAtLimitReached: BlackboardID_Int;

  public let totalShotsFired: BlackboardID_Int;

  public let shotsInBurstFired: BlackboardID_Int;

  public let desiredNumberOfShots: BlackboardID_Int;

  public let nextShotTimeStamp: BlackboardID_Float;

  public let shotTimeStamp: BlackboardID_Float;

  public let maxChargedTimeStamp: BlackboardID_Float;

  public let chargeStartTimeStamp: BlackboardID_Float;

  public let fullyCharged: BlackboardID_Bool;

  public let weaponOverheated: BlackboardID_Bool;

  public let requestedTriggerMode: BlackboardID_Int;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }

  public final const func Initialize(blackboard: ref<IBlackboard>) -> Void {
    blackboard.SetInt(this.totalShotsFired, 0);
  }
}

public class AICoverDataDef extends AIBlackboardDef {

  public let exposureMethod: BlackboardID_Name;

  public let fallbackExposureMethod: BlackboardID_Name;

  public let lastAvailableMethods: BlackboardID_Uint;

  public let currentlyExposed: BlackboardID_Bool;

  public let commandExposureMethods: BlackboardID_Variant;

  public let commandCoverOverride: BlackboardID_Bool;

  public let currentCoverStance: BlackboardID_Name;

  public let desiredCoverStance: BlackboardID_Name;

  public let lastCoverPreset: BlackboardID_Name;

  public let lastInitialCoverPreset: BlackboardID_Name;

  public let lastCoverChangeThreshold: BlackboardID_Float;

  public let lastVisibilityCheckTimestamp: BlackboardID_Float;

  public let currentRing: BlackboardID_Variant;

  public let lastCoverRing: BlackboardID_Variant;

  public let lastDebugCoverPreset: BlackboardID_Int;

  public let firstCoverEvaluationDone: BlackboardID_Bool;

  public let startCoverEvaluationTimeStamp: BlackboardID_Float;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }

  public final const func Initialize(blackboard: ref<IBlackboard>) -> Void {
    blackboard.SetVariant(this.currentRing, ToVariant(gamedataAIRingType.Invalid));
    blackboard.SetVariant(this.lastCoverRing, ToVariant(gamedataAIRingType.Invalid));
    blackboard.SetFloat(this.startCoverEvaluationTimeStamp, -1.00);
  }
}

public class UI_ActivityLogDef extends BlackboardDefinition {

  public let activityLogHide: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_LevelUpDef extends BlackboardDefinition {

  public let level: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class AIActionDataDef extends AIBlackboardDef {

  public let ownerMeleeAttackBlockedCount: BlackboardID_Int;

  public let ownerMeleeAttackParriedCount: BlackboardID_Int;

  public let ownerMeleeAttackDodgedCount: BlackboardID_Int;

  public let ownerLastAttackTimeStamp: BlackboardID_Float;

  public let ownerLastAttackName: BlackboardID_Name;

  public let ownerCurrentAnimVariationSet: BlackboardID_Bool;

  public let ownerLastAnimVariation: BlackboardID_Int;

  public let ownerItemsToEquip: BlackboardID_Variant;

  public let ownerItemsUnequipped: BlackboardID_Variant;

  public let ownerItemsForceUnequipped: BlackboardID_Variant;

  public let ownerLastEquippedItems: BlackboardID_Variant;

  public let ownerLastUnequipTimestamp: BlackboardID_Float;

  public let ownerEquipItemTime: BlackboardID_Float;

  public let ownerEquipDuration: BlackboardID_Float;

  public let dropItemOnUnequip: BlackboardID_Bool;

  public let archetypeEffectorsApplied: BlackboardID_Bool;

  public let ownerTimeDilation: BlackboardID_Float;

  public let operationHasBeenProcessed: BlackboardID_Bool;

  public let weaponTrailInitialised: BlackboardID_Bool;

  public let weaponTrailAborted: BlackboardID_Bool;

  public let netrunner: BlackboardID_Variant;

  public let netrunnerProxy: BlackboardID_Variant;

  public let netrunnerTarget: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }

  public final const func Initialize(blackboard: ref<IBlackboard>) -> Void {
    blackboard.SetInt(this.ownerLastAnimVariation, -1);
    blackboard.SetFloat(this.ownerTimeDilation, -1.00);
  }
}

public class AIActionBossDataDef extends AIBlackboardDef {

  public let excludedWaypointPosition: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }
}

public class UI_CodexSystemDef extends BlackboardDefinition {

  public let CodexUpdated: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_ItemModSystemDef extends BlackboardDefinition {

  public let ItemModSystemUpdated: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class DeviceTakeControlDef extends BlackboardDefinition {

  public let DevicesChain: BlackboardID_Variant;

  public let ActiveDevice: BlackboardID_EntityID;

  public let IsDeviceWorking: BlackboardID_Bool;

  public let ChainLocked: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class TaggedObjectsListDef extends BlackboardDefinition {

  public let taggedObjectsList: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class AdHocAnimationDef extends BlackboardDefinition {

  public let IsActive: BlackboardID_Bool;

  public let AnimationIndex: BlackboardID_Int;

  public let UseBothHands: BlackboardID_Bool;

  public let UnequipWeapon: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class QuickMeleeDataDef extends BlackboardDefinition {

  public let NPCHit: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class PlayerSecureAreaDef extends BlackboardDefinition {

  public let inside: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_VendorDef extends BlackboardDefinition {

  public let VendorData: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_BriefingDef extends BlackboardDefinition {

  public let BriefingToOpen: BlackboardID_String;

  public let BriefingSize: BlackboardID_Variant;

  public let BriefingAlignment: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_EquipmentDef extends BlackboardDefinition {

  public let itemEquipped: BlackboardID_Variant;

  public let lastModifiedArea: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_CraftingDef extends BlackboardDefinition {

  public let lastCommand: BlackboardID_Variant;

  public let lastItem: BlackboardID_Variant;

  public let lastIngredients: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_ItemLogDef extends BlackboardDefinition {

  public let ItemLogItem: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class CW_MuteArmDef extends BlackboardDefinition {

  public let MuteArmActive: BlackboardID_Bool;

  public let MuteArmRadius: BlackboardID_Float;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_ChatBoxDef extends BlackboardDefinition {

  public let TextList: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_HUDNarrationLogDef extends BlackboardDefinition {

  public let LastEvent: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_NarrativePlateDef extends BlackboardDefinition {

  public let PlateData: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_CompanionDef extends BlackboardDefinition {

  public let flatHeadSpawned: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_HackingDef extends BlackboardDefinition {

  public let ammoIndicator: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_StealthDef extends BlackboardDefinition {

  public let CombatDebug: BlackboardID_Bool;

  public let numberOfCombatants: BlackboardID_Uint;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class PhotoModeDef extends BlackboardDefinition {

  public let IsActive: BlackboardID_Bool;

  public let PlayerHealthState: BlackboardID_Uint;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class GameplaySettingsDef extends BlackboardDefinition {

  public let DisableAutomaticSwitchToVehicleTPP: BlackboardID_Bool;

  public let EnableVehicleToggleSummonMode: BlackboardID_Bool;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_TopbarHubMenuDef extends BlackboardDefinition {

  public let IsSubmenuHidden: BlackboardID_Bool;

  public let MetaQuestStatus: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}

public class UI_SceneScreenDef extends BlackboardDefinition {

  public let AnimName: BlackboardID_Name;

  public final const func AutoCreateInSystem() -> Bool {
    return false;
  }
}

public class UI_PointOfNoReturnRewardScreenDef extends BlackboardDefinition {

  public let Rewards: BlackboardID_Variant;

  public final const func AutoCreateInSystem() -> Bool {
    return true;
  }
}
