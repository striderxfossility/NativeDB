
public native class MappinsContainerController extends inkProjectedHUDGameController {

  protected native let psmVision: gamePSMVision;

  protected native let psmCombat: gamePSMCombat;

  protected native let psmZone: gamePSMZones;

  protected final native func GetSpawnContainer() -> wref<inkCompoundWidget>;

  public func CreateMappinUIProfile(mappin: wref<IMappin>, mappinVariant: gamedataMappinVariant, customData: ref<MappinControllerCustomData>) -> MappinUIProfile {
    return MappinUIProfile.None();
  }
}

public native class CyberspaceMappinsContainerController extends MappinsContainerController {

  public func CreateMappinUIProfile(mappin: wref<IMappin>, mappinVariant: gamedataMappinVariant, customData: ref<MappinControllerCustomData>) -> MappinUIProfile {
    switch mappinVariant {
      case gamedataMappinVariant.CyberspaceObject:
        return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\mappins\\cyberspace\\cyberspace_object_mappin.inkwidget", t"MappinUISpawnProfile.Always");
      case gamedataMappinVariant.CyberspaceNPC:
        return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\mappins\\cyberspace\\cyberspace_object_npc.inkwidget", t"MappinUISpawnProfile.Always");
    };
    return MappinUIProfile.None();
  }
}

public class CyberspaceMappinController extends BaseQuestMappinController {

  public edit let m_image: inkImageRef;

  protected cb func OnIntro() -> Bool {
    let mappin: wref<IMappin> = this.GetMappin();
    let texturePart: CName = StringToName(mappin.GetDisplayName());
    if inkImageRef.IsTexturePartExist(this.m_image, texturePart) {
      inkImageRef.SetTexturePart(this.m_image, texturePart);
    };
  }
}

public native class WorldMappinsContainerController extends MappinsContainerController {

  public func CreateMappinUIProfile(mappin: wref<IMappin>, mappinVariant: gamedataMappinVariant, customData: ref<MappinControllerCustomData>) -> MappinUIProfile {
    let questAnimationRecord: ref<UIAnimation_Record>;
    let questMappin: wref<QuestMappin>;
    let stealthMappin: wref<StealthMappin>;
    let gameplayRoleData: ref<GameplayRoleMappinData> = mappin.GetScriptData() as GameplayRoleMappinData;
    let defaultRuntimeProfile: TweakDBID = t"WorldMappinUIProfile.Default";
    let defaultWidgetResource: ResRef = r"base\\gameplay\\gui\\widgets\\mappins\\quest\\default_mappin.inkwidget";
    if mappin.IsExactlyA(n"gamemappinsStealthMappin") {
      stealthMappin = mappin as StealthMappin;
      if stealthMappin.IsCrowdNPC() {
        return MappinUIProfile.None();
      };
      return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\mappins\\stealth\\stealth_default_mappin.inkwidget", t"MappinUISpawnProfile.Stealth", t"WorldMappinUIProfile.Stealth");
    };
    if mappin.IsExactlyA(n"gamemappinsRemotePlayerMappin") {
      return MappinUIProfile.Create(r"multi\\gameplay\\gui\\widgets\\world_mappins\\remote_player_mappin.inkwidget", t"MappinUISpawnProfile.Always", defaultRuntimeProfile);
    };
    if mappin.IsExactlyA(n"gamemappinsPingSystemMappin") {
      return MappinUIProfile.Create(r"multi\\gameplay\\gui\\widgets\\world_mappins\\pingsystem_mappin.inkwidget", t"MappinUISpawnProfile.Always", defaultRuntimeProfile);
    };
    if mappin.IsExactlyA(n"gamemappinsInteractionMappin") {
      return MappinUIProfile.Create(defaultWidgetResource, t"MappinUISpawnProfile.ShortRange", t"WorldMappinUIProfile.Interaction");
    };
    if mappin.IsExactlyA(n"gamemappinsPointOfInterestMappin") {
      if MappinUIUtils.IsMappinServicePoint(mappinVariant) {
        return MappinUIProfile.Create(defaultWidgetResource, t"MappinUISpawnProfile.ShortRange", t"WorldMappinUIProfile.ServicePoint");
      };
      if Equals(mappinVariant, gamedataMappinVariant.FixerVariant) {
        return MappinUIProfile.Create(defaultWidgetResource, t"MappinUISpawnProfile.ShortRange", t"WorldMappinUIProfile.Fixer");
      };
      return MappinUIProfile.Create(defaultWidgetResource, t"MappinUISpawnProfile.ShortRange", defaultRuntimeProfile);
    };
    if Equals(mappinVariant, gamedataMappinVariant.QuickHackVariant) {
      return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\mappins\\interaction\\quick_hack_mappin.inkwidget", t"MappinUISpawnProfile.ShortRange", t"WorldMappinUIProfile.QuickHack");
    };
    if Equals(mappinVariant, gamedataMappinVariant.PhoneCallVariant) {
      return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\mappins\\interaction\\quick_hack_mappin.inkwidget", t"MappinUISpawnProfile.Always", defaultRuntimeProfile);
    };
    if Equals(mappinVariant, gamedataMappinVariant.VehicleVariant) || Equals(mappinVariant, gamedataMappinVariant.Zzz03_MotorcycleVariant) {
      return MappinUIProfile.Create(defaultWidgetResource, t"MappinUISpawnProfile.LongRange", t"WorldMappinUIProfile.Vehicle");
    };
    if gameplayRoleData != null {
      if Equals(mappinVariant, gamedataMappinVariant.FocusClueVariant) {
        return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\mappins\\gameplay\\gameplay_mappin.inkwidget", t"MappinUISpawnProfile.Always", t"WorldMappinUIProfile.FocusClue");
      };
      if Equals(mappinVariant, gamedataMappinVariant.LootVariant) {
        return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\mappins\\gameplay\\gameplay_mappin.inkwidget", t"MappinUISpawnProfile.Always", t"WorldMappinUIProfile.Loot");
      };
      return MappinUIProfile.Create(r"base\\gameplay\\gui\\widgets\\mappins\\gameplay\\gameplay_mappin.inkwidget", t"MappinUISpawnProfile.Always", t"WorldMappinUIProfile.GameplayRole");
    };
    if Equals(mappinVariant, gamedataMappinVariant.FastTravelVariant) {
      return MappinUIProfile.Create(defaultWidgetResource, t"MappinUISpawnProfile.ShortRange", t"WorldMappinUIProfile.FastTravel");
    };
    if Equals(mappinVariant, gamedataMappinVariant.ServicePointDropPointVariant) {
      return MappinUIProfile.Create(defaultWidgetResource, t"MappinUISpawnProfile.ShortRange", t"WorldMappinUIProfile.DropPoint");
    };
    if mappin.IsQuestMappin() {
      questMappin = mappin as QuestMappin;
      if IsDefined(questMappin) {
        if questMappin.IsUIAnimation() {
          questAnimationRecord = TweakDBInterface.GetUIAnimationRecord(questMappin.GetUIAnimationRecordID());
          if ResRef.IsValid(questAnimationRecord.WidgetResource()) && NotEquals(questAnimationRecord.AnimationName(), n"") {
            return MappinUIProfile.Create(questAnimationRecord.WidgetResource(), t"MappinUISpawnProfile.Always", defaultRuntimeProfile);
          };
        } else {
          return MappinUIProfile.Create(defaultWidgetResource, t"MappinUISpawnProfile.Always", t"WorldMappinUIProfile.Quest");
        };
      };
    };
    if customData != null && (customData as TrackedMappinControllerCustomData) != null {
      return MappinUIProfile.Create(defaultWidgetResource, t"MappinUISpawnProfile.Always", defaultRuntimeProfile);
    };
    return MappinUIProfile.Create(defaultWidgetResource, t"MappinUISpawnProfile.MediumRange", defaultRuntimeProfile);
  }
}
