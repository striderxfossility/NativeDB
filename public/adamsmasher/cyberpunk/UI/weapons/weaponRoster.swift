
public class weaponRosterGameController extends inkHUDGameController {

  private edit let m_CurrentAmmoRef: inkTextRef;

  private edit let m_AllAmmoRef: inkTextRef;

  private edit let m_ammoWrapper: inkWidgetRef;

  private edit let m_container: inkWidgetRef;

  private edit let m_warningMessageWraper: inkWidgetRef;

  private edit let m_smartLinkFirmwareOnline: inkCompoundRef;

  private edit let m_smartLinkFirmwareOffline: inkCompoundRef;

  private edit let m_weaponIcon: inkImageRef;

  private edit const let m_FireModes: array<inkImageRef>;

  private edit const let m_WeaponMods: array<inkImageRef>;

  private edit let m_modHolder: inkWidgetRef;

  private edit let m_weaponName: inkTextRef;

  private edit let m_damageTypeRef: inkWidgetRef;

  private edit let m_crouchIcon: inkImageRef;

  @default(weaponRosterGameController, true)
  private let m_folded: Bool;

  private let m_InventoryManager: ref<InventoryDataManagerV2>;

  private let m_weaponItemData: InventoryItemData;

  private let m_damageTypeIndicator: wref<DamageTypeIndicator>;

  private let m_WeaponAreas: array<gamedataItemType>;

  private let m_BBWeaponList: ref<CallbackHandle>;

  private let m_BBAmmoLooted: ref<CallbackHandle>;

  private let m_BBCurrentWeapon: ref<CallbackHandle>;

  private let m_LocomotionStateBlackboardId: ref<CallbackHandle>;

  private let m_VisionStateBlackboardId: ref<CallbackHandle>;

  private let m_UIStateBlackboardId: ref<CallbackHandle>;

  private let m_PlayerSpawnedCallbackID: ref<CallbackHandle>;

  private let m_ammoHackedListenerId: ref<CallbackHandle>;

  private let m_BufferedRosterData: ref<SlotDataHolder>;

  private let m_UIBlackboard: wref<IBlackboard>;

  private let m_ActiveWeapon: SlotWeaponData;

  private let m_hackingBlackboard: wref<IBlackboard>;

  private let m_Player: wref<PlayerPuppet>;

  private let m_outOfAmmoAnim: ref<inkAnimProxy>;

  private let m_transitionAnimProxy: ref<inkAnimProxy>;

  private let m_blackboard: wref<IBlackboard>;

  private let m_bbDefinition: ref<UIInteractionsDef>;

  private let m_onMagazineAmmoCount: ref<CallbackHandle>;

  private let m_dataListenerId: ref<CallbackHandle>;

  private let m_weaponBlackboard: wref<IBlackboard>;

  private let m_weaponParamsListenerId: ref<CallbackHandle>;

  private let m_bufferedMaxAmmo: Int32;

  private let m_bufferedAmmoId: Int32;

  private let m_genderName: CName;

  protected cb func OnInitialize() -> Bool {
    this.PlayInitFoldingAnim();
    inkWidgetRef.SetVisible(this.m_warningMessageWraper, false);
    this.m_damageTypeIndicator = inkWidgetRef.GetController(this.m_damageTypeRef) as DamageTypeIndicator;
    this.m_bbDefinition = GetAllBlackboardDefs().UIInteractions;
    this.m_blackboard = this.GetBlackboardSystem().Get(this.m_bbDefinition);
    this.m_UIBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_EquipmentData);
    this.m_hackingBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Hacking);
    this.m_weaponBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ActiveWeaponData);
    inkWidgetRef.SetVisible(this.m_smartLinkFirmwareOffline, false);
    inkWidgetRef.SetVisible(this.m_smartLinkFirmwareOnline, false);
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_InventoryManager.UnInitialize();
    this.m_blackboard = null;
    this.m_UIBlackboard = null;
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_Player = playerPuppet as PlayerPuppet;
    this.m_InventoryManager = new InventoryDataManagerV2();
    this.m_InventoryManager.Initialize(this.m_Player);
    this.m_genderName = this.m_Player.GetResolvedGenderName();
    this.m_WeaponAreas = InventoryDataManagerV2.GetInventoryWeaponTypes();
    this.RegisterBB();
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.UnregisterBB();
    this.m_Player = null;
  }

  private final func RegisterBB() -> Void {
    let playerSMBB: ref<IBlackboard>;
    this.m_dataListenerId = this.m_blackboard.RegisterDelayedListenerVariant(this.m_bbDefinition.LootData, this, n"OnUpdateData");
    this.m_BBWeaponList = this.m_UIBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_EquipmentData.EquipmentData, this, n"OnWeaponDataChanged");
    this.m_BBAmmoLooted = this.m_UIBlackboard.RegisterListenerBool(GetAllBlackboardDefs().UI_EquipmentData.ammoLooted, this, n"OnAmmoLooted");
    this.m_UIBlackboard.SignalVariant(GetAllBlackboardDefs().UI_EquipmentData.EquipmentData);
    this.m_UIBlackboard.SignalBool(GetAllBlackboardDefs().UI_EquipmentData.ammoLooted);
    this.m_onMagazineAmmoCount = this.m_blackboard.RegisterListenerUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCount, this, n"OnMagazineAmmoCount");
    this.m_weaponParamsListenerId = this.m_weaponBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_ActiveWeaponData.SmartGunParams, this, n"OnSmartGunParams");
    this.m_ammoHackedListenerId = this.m_hackingBlackboard.RegisterDelayedListenerBool(GetAllBlackboardDefs().UI_Hacking.ammoIndicator, this, n"OnAmmoIndicatorHacked");
    if IsDefined(this.m_Player) && this.m_Player.IsControlledByLocalPeer() {
      playerSMBB = this.GetPSMBlackboard(this.m_Player);
      this.m_VisionStateBlackboardId = playerSMBB.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vision, this, n"OnPSMVisionStateChanged");
      this.m_LocomotionStateBlackboardId = playerSMBB.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Locomotion, this, n"OnPSMLocomotionStateChanged");
    };
  }

  private final func UnregisterBB() -> Void {
    let playerSMBB: ref<IBlackboard>;
    if IsDefined(this.m_Player) {
      playerSMBB = this.GetPSMBlackboard(this.m_Player);
      playerSMBB.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vision, this.m_VisionStateBlackboardId);
      playerSMBB.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Locomotion, this.m_LocomotionStateBlackboardId);
    };
    this.m_hackingBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_Hacking.ammoIndicator, this.m_ammoHackedListenerId);
    this.m_UIBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_EquipmentData.EquipmentData, this.m_BBWeaponList);
    this.m_UIBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().UI_EquipmentData.ammoLooted, this.m_BBAmmoLooted);
    this.m_blackboard.UnregisterDelayedListener(this.m_bbDefinition.LootData, this.m_dataListenerId);
    this.m_weaponBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ActiveWeaponData.SmartGunParams, this.m_weaponParamsListenerId);
  }

  protected cb func OnUpdateData(value: Variant) -> Bool {
    if IsDefined(this.m_UIBlackboard) {
      this.m_UIBlackboard.SignalVariant(GetAllBlackboardDefs().UI_EquipmentData.EquipmentData);
    };
  }

  protected cb func OnAmmoIndicatorHacked(value: Bool) -> Bool {
    inkWidgetRef.Get(this.m_container).SetEffectEnabled(inkEffectType.Glitch, n"hacking", value);
  }

  protected cb func OnPSMVisionStateChanged(value: Int32) -> Bool {
    let newState: gamePSMVision = IntEnum(value);
    switch newState {
      case gamePSMVision.Default:
        if ItemID.IsValid(this.m_ActiveWeapon.weaponID) {
          this.PlayUnfold();
        };
        break;
      case gamePSMVision.Focus:
        this.PlayFold();
    };
  }

  protected cb func OnPSMLocomotionStateChanged(value: Int32) -> Bool {
    if Equals(IntEnum(value), gamePSMLocomotionStates.Crouch) {
      if Equals(this.m_genderName, n"Female") {
        inkImageRef.SetTexturePart(this.m_crouchIcon, n"crouch_female");
      } else {
        inkImageRef.SetTexturePart(this.m_crouchIcon, n"crouch");
      };
    } else {
      if Equals(this.m_genderName, n"Female") {
        inkImageRef.SetTexturePart(this.m_crouchIcon, n"stand_female");
      } else {
        inkImageRef.SetTexturePart(this.m_crouchIcon, n"stand");
      };
    };
  }

  protected cb func OnAmmoLooted(value: Bool) -> Bool {
    let allAmmoCount: Int32 = RPGManager.GetAmmoCountValue(this.m_Player, this.m_ActiveWeapon.weaponID) - this.m_ActiveWeapon.ammoCurrent;
    inkTextRef.SetText(this.m_AllAmmoRef, this.GetAmmoText(allAmmoCount, 4));
  }

  protected cb func OnSmartGunParams(argParams: Variant) -> Bool {
    let smartData: ref<smartGunUIParameters> = FromVariant(argParams);
    if Equals(RPGManager.GetWeaponEvolution(InventoryItemData.GetID(this.m_weaponItemData)), gamedataWeaponEvolution.Smart) {
      inkWidgetRef.SetVisible(this.m_smartLinkFirmwareOffline, !smartData.hasRequiredCyberware);
      inkWidgetRef.SetVisible(this.m_smartLinkFirmwareOnline, smartData.hasRequiredCyberware);
    } else {
      inkWidgetRef.SetVisible(this.m_smartLinkFirmwareOffline, false);
      inkWidgetRef.SetVisible(this.m_smartLinkFirmwareOnline, false);
    };
  }

  protected cb func OnWeaponDataChanged(value: Variant) -> Bool {
    let item: ref<gameItemData>;
    let weaponItemType: gamedataItemType;
    this.m_BufferedRosterData = FromVariant(value);
    let currentData: SlotWeaponData = this.m_BufferedRosterData.weapon;
    if ItemID.IsValid(currentData.weaponID) {
      if this.m_ActiveWeapon.weaponID != currentData.weaponID {
        item = this.m_InventoryManager.GetPlayerItemData(currentData.weaponID);
        this.m_weaponItemData = this.m_InventoryManager.GetInventoryItemData(item);
      };
      this.m_ActiveWeapon = currentData;
      weaponItemType = InventoryItemData.GetItemType(this.m_weaponItemData);
      this.SetRosterSlotData(Equals(weaponItemType, gamedataItemType.Wea_Melee) || Equals(weaponItemType, gamedataItemType.Wea_Fists) || Equals(weaponItemType, gamedataItemType.Wea_Hammer) || Equals(weaponItemType, gamedataItemType.Wea_Katana) || Equals(weaponItemType, gamedataItemType.Wea_Knife) || Equals(weaponItemType, gamedataItemType.Wea_OneHandedClub) || Equals(weaponItemType, gamedataItemType.Wea_ShortBlade) || Equals(weaponItemType, gamedataItemType.Wea_TwoHandedClub) || Equals(weaponItemType, gamedataItemType.Wea_LongBlade));
      this.PlayUnfold();
      if NotEquals(RPGManager.GetWeaponEvolution(InventoryItemData.GetID(this.m_weaponItemData)), gamedataWeaponEvolution.Smart) {
        inkWidgetRef.SetVisible(this.m_smartLinkFirmwareOffline, false);
        inkWidgetRef.SetVisible(this.m_smartLinkFirmwareOnline, false);
      };
    } else {
      this.PlayFold();
    };
  }

  private final func PlayFold() -> Void {
    if this.m_folded {
      return;
    };
    this.m_folded = true;
    if IsDefined(this.m_transitionAnimProxy) {
      this.m_transitionAnimProxy.Stop();
      this.m_transitionAnimProxy = null;
    };
    this.m_transitionAnimProxy = this.PlayLibraryAnimation(n"fold");
  }

  private final func PlayUnfold() -> Void {
    if !this.m_folded {
      return;
    };
    this.m_folded = false;
    if IsDefined(this.m_transitionAnimProxy) {
      this.m_transitionAnimProxy.Stop();
      this.m_transitionAnimProxy = null;
    };
    this.m_transitionAnimProxy = this.PlayLibraryAnimation(n"unfold");
  }

  private final func SetRosterSlotData(isMelee: Bool) -> Void {
    let iconName: CName;
    let options: inkAnimOptions;
    let showAmmoCounter: Bool;
    options.loopType = inkanimLoopType.Cycle;
    options.loopInfinite = true;
    let allAmmoCount: Int32 = RPGManager.GetAmmoCountValue(this.m_Player, this.m_ActiveWeapon.weaponID) - this.m_ActiveWeapon.ammoCurrent;
    inkTextRef.SetText(this.m_CurrentAmmoRef, this.GetAmmoText(this.m_ActiveWeapon.ammoCurrent, 3));
    inkTextRef.SetText(this.m_AllAmmoRef, this.GetAmmoText(allAmmoCount, 4));
    showAmmoCounter = GameInstance.GetQuestsSystem(this.m_Player.GetGame()).GetFact(n"q001_hide_ammo_counter") == 0;
    inkWidgetRef.SetVisible(this.m_CurrentAmmoRef, showAmmoCounter);
    inkWidgetRef.SetVisible(this.m_AllAmmoRef, showAmmoCounter && !this.m_Player.IsReplacer());
    if IsDefined(this.m_outOfAmmoAnim) && this.m_outOfAmmoAnim.IsPlaying() {
      this.m_outOfAmmoAnim.Stop();
      inkWidgetRef.SetVisible(this.m_warningMessageWraper, false);
    };
    iconName = this.GetItemTypeIcon();
    this.LoadWeaponIcon();
    if isMelee {
      inkWidgetRef.SetVisible(this.m_CurrentAmmoRef, false);
      inkWidgetRef.SetVisible(this.m_AllAmmoRef, false);
    } else {
      if this.m_ActiveWeapon.ammoCurrent == 0 && allAmmoCount == 0 && NotEquals(iconName, n"") {
        this.m_outOfAmmoAnim = this.PlayLibraryAnimation(n"out_of_ammo", options);
        inkWidgetRef.SetVisible(this.m_warningMessageWraper, true);
      } else {
        if IsDefined(this.m_outOfAmmoAnim) {
          this.m_outOfAmmoAnim.Stop();
        };
        inkWidgetRef.SetVisible(this.m_warningMessageWraper, false);
      };
      if this.m_ActiveWeapon.ammoCurrent == 0 && allAmmoCount == 0 && Equals(iconName, n"") {
        inkWidgetRef.SetVisible(this.m_CurrentAmmoRef, false);
        inkWidgetRef.SetVisible(this.m_AllAmmoRef, false);
      };
    };
    if IsDefined(this.m_damageTypeIndicator) {
      this.m_damageTypeIndicator.Setup(InventoryItemData.GetDamageType(this.m_weaponItemData));
    };
    inkTextRef.SetText(this.m_weaponName, InventoryItemData.GetName(this.m_weaponItemData));
    this.SetTriggerModeIcons();
  }

  private final func LoadWeaponIcon() -> Void {
    let record: ref<WeaponItem_Record>;
    if ItemID.IsValid(this.m_ActiveWeapon.weaponID) {
      record = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(this.m_ActiveWeapon.weaponID));
      if record != null {
        InkImageUtils.RequestSetImage(this, this.m_weaponIcon, record.HudIcon().GetID());
      };
    };
  }

  private final func SetTriggerModeIcons() -> Void {
    let i: Int32;
    if ArraySize(this.m_ActiveWeapon.triggerModeList) > 0 {
      inkWidgetRef.SetVisible(this.m_modHolder, true);
    } else {
      inkWidgetRef.SetVisible(this.m_modHolder, false);
    };
    i = 0;
    while i < ArraySize(this.m_ActiveWeapon.triggerModeList) {
      if Equals(this.m_ActiveWeapon.triggerModeList[i], this.m_ActiveWeapon.triggerModeCurrent) {
        inkImageRef.SetTexturePart(this.m_FireModes[i], this.HelperFireModeIcon(this.m_ActiveWeapon.triggerModeList[i]));
        inkWidgetRef.SetOpacity(this.m_FireModes[i], 1.00);
      } else {
        inkImageRef.SetTexturePart(this.m_FireModes[i], this.HelperFireModeIcon(this.m_ActiveWeapon.triggerModeList[i]));
        inkWidgetRef.SetOpacity(this.m_FireModes[i], 0.30);
      };
      i += 1;
    };
  }

  private final func GetItemTypeIcon() -> CName {
    let iconPath: CName;
    switch InventoryItemData.GetItemType(this.m_weaponItemData) {
      case gamedataItemType.Wea_AssaultRifle:
        iconPath = n"tech_rifle";
        break;
      case gamedataItemType.Wea_Handgun:
        iconPath = n"pistol";
        break;
      case gamedataItemType.Wea_Katana:
        iconPath = n"katana";
        break;
      case gamedataItemType.Wea_Knife:
        iconPath = n"katana";
        break;
      case gamedataItemType.Wea_LightMachineGun:
        iconPath = n"smart_gun";
        break;
      case gamedataItemType.Wea_LongBlade:
        iconPath = n"katana";
        break;
      case gamedataItemType.Wea_Melee:
        iconPath = n"tech_rifle";
        break;
      case gamedataItemType.Wea_OneHandedClub:
        iconPath = n"tech_rifle";
        break;
      case gamedataItemType.Wea_PrecisionRifle:
        iconPath = n"tech_rifle";
        break;
      case gamedataItemType.Wea_Revolver:
        iconPath = n"pistol";
        break;
      case gamedataItemType.Wea_Rifle:
        iconPath = n"tech_rifle";
        break;
      case gamedataItemType.Wea_ShortBlade:
        iconPath = n"katana";
        break;
      case gamedataItemType.Wea_Shotgun:
        iconPath = n"shotgun";
        break;
      case gamedataItemType.Wea_ShotgunDual:
        iconPath = n"shotgun";
        break;
      case gamedataItemType.Wea_SniperRifle:
        iconPath = n"tech_rifle";
        break;
      case gamedataItemType.Wea_SubmachineGun:
        iconPath = n"smart_gun";
        break;
      case gamedataItemType.Wea_TwoHandedClub:
        iconPath = n"katana";
        break;
      case gamedataItemType.Wea_Fists:
        iconPath = n"katana";
        break;
      default:
        iconPath = n"";
    };
    return iconPath;
  }

  private final func HelperFireModeIcon(type: gamedataTriggerMode) -> CName {
    let iconPath: CName;
    switch type {
      case gamedataTriggerMode.SemiAuto:
        iconPath = n"semi_auto_icon";
        break;
      case gamedataTriggerMode.Burst:
        iconPath = n"burst_icon";
        break;
      case gamedataTriggerMode.FullAuto:
        iconPath = n"auto_icon";
        break;
      case gamedataTriggerMode.Charge:
        iconPath = n"charge_icon";
    };
    return iconPath;
  }

  private final func GetUnreservedAmmoQuantityByType(ammoID: ItemID) -> Int32 {
    let ammoData: AmmoData;
    let i: Int32 = 0;
    while i < ArraySize(this.m_BufferedRosterData.ammoData) {
      ammoData = this.m_BufferedRosterData.ammoData[i];
      if ammoData.id == ammoID {
        return ammoData.available - ammoData.equipped;
      };
      i += 1;
    };
    return 0;
  }

  private final func GetAmmoText(ammoCount: Int32, textLength: Int32) -> String {
    return SpaceFill(IntToString(Max(ammoCount, 0)), textLength, ESpaceFillMode.JustifyRight, "0");
  }
}
