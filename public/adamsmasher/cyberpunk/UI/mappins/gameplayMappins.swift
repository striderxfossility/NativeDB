
public class GameplayMappinController extends QuestMappinController {

  private let anim: ref<inkAnimProxy>;

  private let m_isVisibleThroughWalls: Bool;

  protected cb func OnUpdate() -> Bool {
    super.OnUpdate();
    this.SetClampVisibility();
  }

  protected func UpdateTrackedState() -> Void {
    let i: Int32;
    let isTagged: Bool = this.IsTagged();
    if isTagged && IsDefined(this.m_runtimeMappin) {
      isTagged = !this.m_runtimeMappin.GetOwnerObjectMarkerPossibility();
    };
    i = 0;
    while i < ArraySize(this.m_taggedWidgets) {
      inkWidgetRef.SetVisible(this.m_taggedWidgets[i], isTagged);
      i += 1;
    };
  }

  private func UpdateVisibility() -> Void {
    if IsDefined(this.m_mappin) {
      this.SetRootVisible(this.m_mappin.IsVisible());
    };
  }

  private final func GetTexturePartForGameplayRole(gameplayRole: EGameplayRole) -> CName {
    switch gameplayRole {
      case EGameplayRole.Alarm:
        return n"trigger_alarm1";
      case EGameplayRole.ControlNetwork:
        return n"control_network_device1";
      case EGameplayRole.ControlOtherDevice:
        return n"control_network_device2";
      case EGameplayRole.ControlSelf:
        return n"control_network_device3";
      case EGameplayRole.CutPower:
        return n"cut_power1";
      case EGameplayRole.Distract:
        return n"distract_enemy3";
      case EGameplayRole.DropPoint:
        return n"drop_point1";
      case EGameplayRole.ExplodeLethal:
        return n"explosive_lethal1";
      case EGameplayRole.ExplodeNoneLethal:
        return n"explosive_non-lethal1";
      case EGameplayRole.Fall:
        return n"fall2";
      case EGameplayRole.GrantInformation:
        return n"grants_information1";
      case EGameplayRole.Clue:
        return n"clue";
      case EGameplayRole.HideBody:
        return n"dispose_body1";
      case EGameplayRole.Loot:
        return n"loot1";
      case EGameplayRole.OpenPath:
        return n"open_path1";
      case EGameplayRole.ClearPath:
        return n"movable1";
      case EGameplayRole.ServicePoint:
        return n"use_servicepoint1";
      case EGameplayRole.Shoot:
        return n"shoots2";
      case EGameplayRole.SpreadGas:
        return n"gas_spread1";
      case EGameplayRole.StoreItems:
        return n"storage1";
      case EGameplayRole.GenericRole:
        return n"distract_enemy3";
    };
    return n"";
  }

  private final func GetTexturePartForDeviceEffect(mappinVariant: gamedataMappinVariant, braindanceLayer: braindanceVisionMode) -> CName {
    switch mappinVariant {
      case gamedataMappinVariant.EffectAlarmVariant:
        return n"main_quest";
      case gamedataMappinVariant.EffectControlNetworkVariant:
        return n"hack1";
      case gamedataMappinVariant.EffectControlOtherDeviceVariant:
        return n"control_network_device3";
      case gamedataMappinVariant.EffectControlSelfVariant:
        return n"control_network_device3";
      case gamedataMappinVariant.EffectCutPowerVariant:
        return n"cut_power1";
      case gamedataMappinVariant.EffectDistractVariant:
        return n"distract_enemy3";
      case gamedataMappinVariant.EffectDropPointVariant:
        return n"drop_point1";
      case gamedataMappinVariant.EffectExplodeLethalVariant:
        return n"explosive_lethal1";
      case gamedataMappinVariant.EffectExplodeNonLethalVariant:
        return n"explosive_non-lethal1";
      case gamedataMappinVariant.EffectFallVariant:
        return n"fall2";
      case gamedataMappinVariant.EffectGrantInformationVariant:
        return n"grants_information1";
      case gamedataMappinVariant.EffectHideBodyVariant:
        return n"dispose_body1";
      case gamedataMappinVariant.EffectLootVariant:
        return n"loot1";
      case gamedataMappinVariant.EffectOpenPathVariant:
        return n"open_path1";
      case gamedataMappinVariant.EffectPushVariant:
        return n"movable1";
      case gamedataMappinVariant.EffectServicePointVariant:
        return n"use_servicepoint1";
      case gamedataMappinVariant.EffectShootVariant:
        return n"shoots2";
      case gamedataMappinVariant.EffectSpreadGasVariant:
        return n"gas_spread1";
      case gamedataMappinVariant.EffectStoreItemsVariant:
        return n"storage1";
      case gamedataMappinVariant.NetrunnerVariant:
        return n"hack1";
      case gamedataMappinVariant.SoloVariant:
        return n"solo1";
      case gamedataMappinVariant.TechieVariant:
        return n"techie1";
      case gamedataMappinVariant.NetrunnerSoloTechieVariant:
        return n"netrunner_solo_techie_variant1";
      case gamedataMappinVariant.NetrunnerSoloVariant:
        return n"netrunner_solo_variant1";
      case gamedataMappinVariant.NetrunnerTechieVariant:
        return n"netrunner_techie_variant1";
      case gamedataMappinVariant.SoloTechieVariant:
        return n"solo_techie_variant1";
      case gamedataMappinVariant.ImportantInteractionVariant:
        return n"skillcheck_device";
      case gamedataMappinVariant.NetrunnerSoloTechieVariant:
        return n"netrunner_solo_techie_variant1";
      case gamedataMappinVariant.NetrunnerSoloVariant:
        return n"netrunner_solo_variant1";
      case gamedataMappinVariant.NetrunnerTechieVariant:
        return n"netrunner_techie_variant1";
      case gamedataMappinVariant.SoloTechieVariant:
        return n"solo_techie_variant1";
      case gamedataMappinVariant.FastTravelVariant:
        return n"fast_travel";
      case gamedataMappinVariant.GenericRoleVariant:
        return n"interaction";
      case gamedataMappinVariant.NPCVariant:
        return n"distract_enemy4";
      case gamedataMappinVariant.LootVariant:
        return n"loot1";
      case gamedataMappinVariant.FocusClueVariant:
        switch braindanceLayer {
          case braindanceVisionMode.Default:
            return n"clue";
          case braindanceVisionMode.Audio:
            return n"clue_audio";
          case braindanceVisionMode.Thermal:
            return n"clue_thermal";
          case gamedataMappinVariant.ImportantInteractionVariant:
            return n"interaction";
          case gamedataMappinVariant.NetrunnerSoloTechieVariant:
            return n"hack1";
          case gamedataMappinVariant.NetrunnerSoloVariant:
            return n"hack1";
          case gamedataMappinVariant.NetrunnerTechieVariant:
            return n"hack1";
          case gamedataMappinVariant.SoloTechieVariant:
            return n"solo1";
        };
      case gamedataMappinVariant.ImportantInteractionVariant:
        return n"interaction";
      case gamedataMappinVariant.NetrunnerSoloTechieVariant:
        return n"hack1";
      case gamedataMappinVariant.NetrunnerSoloVariant:
        return n"hack1";
      case gamedataMappinVariant.NetrunnerTechieVariant:
        return n"hack1";
      case gamedataMappinVariant.SoloTechieVariant:
        return n"solo1";
    };
    return n"";
  }

  private func ComputeRootState() -> CName {
    let returnValue: CName;
    let visualState: EMappinVisualState = this.GetMappinVisualState();
    let quality: gamedataQuality = this.GetQuality();
    if this.IsQuest() {
      returnValue = n"Quest";
    } else {
      if NotEquals(quality, gamedataQuality.Invalid) && NotEquals(quality, gamedataQuality.Random) {
        if this.IsIconic() {
          returnValue = n"Iconic";
        } else {
          switch quality {
            case gamedataQuality.Common:
              returnValue = n"Common";
              break;
            case gamedataQuality.Epic:
              returnValue = n"Epic";
              break;
            case gamedataQuality.Legendary:
              returnValue = n"Legendary";
              break;
            case gamedataQuality.Rare:
              returnValue = n"Rare";
              break;
            case gamedataQuality.Uncommon:
              returnValue = n"Uncommon";
              break;
            case gamedataQuality.Iconic:
              returnValue = n"Iconic";
              break;
            default:
              returnValue = n"Default";
          };
        };
      } else {
        switch visualState {
          case EMappinVisualState.Inactive:
            returnValue = n"Inactive";
            break;
          case EMappinVisualState.Available:
            returnValue = n"Available";
            break;
          case EMappinVisualState.Unavailable:
            returnValue = n"Unavailable";
            break;
          case EMappinVisualState.Default:
            returnValue = n"Default";
        };
      };
    };
    if this.ShouldBeClamped() {
      returnValue = n"Distraction";
    };
    this.UpdateVisibilityThroughWalls();
    return returnValue;
  }

  private final func UpdateVisibilityThroughWalls() -> Void {
    let data: ref<GameplayRoleMappinData> = this.GetVisualData();
    if data == null {
      return;
    };
    if NotEquals(data.m_visibleThroughWalls, this.m_isVisibleThroughWalls) {
      this.m_runtimeMappin.EnableVisibilityThroughWalls(data.m_visibleThroughWalls);
    };
    this.m_isVisibleThroughWalls = data.m_visibleThroughWalls;
  }

  private func UpdateIcon() -> Void {
    let iconID: TweakDBID;
    let iconName: CName;
    let roleMappinData: ref<GameplayRoleMappinData>;
    if IsDefined(this.m_mappin) {
      roleMappinData = this.m_mappin.GetScriptData() as GameplayRoleMappinData;
    };
    if IsDefined(roleMappinData) && roleMappinData.m_isScanningCluesBlocked {
      iconID = t"MappinIcons.ClueLaterMappin";
    } else {
      if IsDefined(roleMappinData) {
        iconID = roleMappinData.m_textureID;
      };
    };
    if !TDBID.IsValid(iconID) && IsDefined(this.m_mappin) {
      iconName = this.GetTexturePartForDeviceEffect(this.m_mappin.GetVariant(), roleMappinData.m_braindanceLayer);
      inkImageRef.SetTexturePart(this.iconWidget, iconName);
    } else {
      this.SetTexture(this.iconWidget, iconID);
    };
    if IsNameValid(iconName) || IsDefined(this.m_mappin) && Equals(this.m_mappin.GetVariant(), gamedataMappinVariant.Invalid) || TDBID.IsValid(iconID) {
      inkWidgetRef.SetVisible(this.m_scanningDiamond, false);
    } else {
      inkWidgetRef.SetVisible(this.m_scanningDiamond, true);
    };
    if this.ShouldBeClamped() {
      inkWidgetRef.SetVisible(this.iconWidget, false);
    };
  }

  private final func GetGameplayRole() -> EGameplayRole {
    return this.GetVisualData().m_gameplayRole;
  }

  private final func SetClampVisibility() -> Void {
    let roleMappinData: ref<GameplayRoleMappinData>;
    if IsDefined(this.m_mappin) {
      roleMappinData = this.m_mappin.GetScriptData() as GameplayRoleMappinData;
    };
    if IsDefined(roleMappinData) && roleMappinData.m_hasOffscreenArrow {
      this.OverrideClamp(true);
    };
  }

  private final func ShouldBeClamped() -> Bool {
    let roleMappinData: ref<GameplayRoleMappinData>;
    if IsDefined(this.m_mappin) {
      roleMappinData = this.m_mappin.GetScriptData() as GameplayRoleMappinData;
    };
    if IsDefined(roleMappinData) && roleMappinData.m_hasOffscreenArrow {
      return true;
    };
    return false;
  }
}
