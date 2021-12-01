
public abstract final native class UIItemsHelper extends IScriptable {

  public final static native func QualityStringToStateName(quality: String) -> CName;

  public final static native func QualityToLocalizationKey(quality: gamedataQuality) -> String;

  public final static native func QualityEnumToName(quality: gamedataQuality) -> CName;

  public final static native func QualityNameToEnum(quality: CName) -> gamedataQuality;

  public final static native func QualityEnumToInt(quality: gamedataQuality) -> Int32;

  public final static native func QualityEnumToString(quality: gamedataQuality) -> String;

  public final static native func QualityIntToName(quality: Int32) -> CName;

  public final static native func QualityStringToInt(quality: String) -> Int32;

  public final static native func QualityNameToInt(quality: CName) -> Int32;

  public final static native func QualityToInt(quality: gamedataQuality) -> Int32;

  public final static native func IntToQuality(quality: Int32) -> gamedataQuality;

  public final static func GetStateNameForDamageType(damageType: gamedataDamageType) -> CName {
    switch damageType {
      case gamedataDamageType.Chemical:
        return n"Chemical";
      case gamedataDamageType.Electric:
        return n"EMP";
      case gamedataDamageType.Physical:
        return n"Physical";
      case gamedataDamageType.Thermal:
        return n"Thermal";
      default:
        return inkWidget.DefaultState();
    };
  }

  public final static func GetIconNameForDamageType(damageType: gamedataDamageType) -> String {
    switch damageType {
      case gamedataDamageType.Chemical:
        return "icon_chemical";
      case gamedataDamageType.Electric:
        return "icon_emp";
      case gamedataDamageType.Physical:
        return "icon_physical";
      case gamedataDamageType.Thermal:
        return "icon_thermal";
      default:
        return "None";
    };
  }

  public final static func GetTweakDBIDForDamageType(damageType: gamedataDamageType) -> TweakDBID {
    switch damageType {
      case gamedataDamageType.Chemical:
        return t"UIIcon.DamageType_Chemical";
      case gamedataDamageType.Electric:
        return t"UIIcon.DamageType_EMP";
      case gamedataDamageType.Physical:
        return t"UIIcon.DamageType_Physical";
      case gamedataDamageType.Thermal:
        return t"UIIcon.DamageType_Thermal";
      default:
        return t"UIIcon.ItemIcon";
    };
  }

  public final static func GetStateNameForType(damageType: gamedataDamageType) -> CName {
    switch damageType {
      case gamedataDamageType.Chemical:
        return n"Chemical";
      case gamedataDamageType.Electric:
        return n"EMP";
      case gamedataDamageType.Physical:
        return n"Physical";
      case gamedataDamageType.Thermal:
        return n"Thermal";
      default:
        return inkWidget.DefaultState();
    };
  }

  public final static func GetStateNameForStat(statType: gamedataStatType) -> CName {
    switch statType {
      case gamedataStatType.ChemicalDamage:
      case gamedataStatType.ChemicalResistance:
        return n"Chemical";
      case gamedataStatType.ElectricResistance:
      case gamedataStatType.ElectricDamage:
        return n"EMP";
      case gamedataStatType.PhysicalResistance:
      case gamedataStatType.PhysicalDamage:
        return n"Physical";
      case gamedataStatType.ThermalDamage:
      case gamedataStatType.ThermalResistance:
        return n"Thermal";
      case gamedataStatType.Health:
        return n"Health";
      default:
        return inkWidget.DefaultState();
    };
  }

  public final static func GetIconNameForStat(statType: gamedataStatType) -> CName {
    switch statType {
      case gamedataStatType.ChemicalDamage:
      case gamedataStatType.ChemicalResistance:
        return n"icon_chemical";
      case gamedataStatType.ElectricResistance:
      case gamedataStatType.ElectricDamage:
        return n"icon_emp";
      case gamedataStatType.PhysicalResistance:
      case gamedataStatType.PhysicalDamage:
        return n"icon_physical";
      case gamedataStatType.ThermalDamage:
      case gamedataStatType.ThermalResistance:
        return n"icon_thermal";
      case gamedataStatType.Health:
        return n"icon_health";
      default:
        return n"";
    };
  }

  public final static func GetBGIconNameForStat(statType: gamedataStatType) -> CName {
    switch statType {
      case gamedataStatType.ChemicalDamage:
      case gamedataStatType.ChemicalResistance:
        return n"scan_bg_3";
      case gamedataStatType.ElectricResistance:
      case gamedataStatType.ElectricDamage:
        return n"scan_bg_2";
      case gamedataStatType.PhysicalResistance:
      case gamedataStatType.PhysicalDamage:
        return n"scan_bg_1";
      case gamedataStatType.ThermalDamage:
      case gamedataStatType.ThermalResistance:
        return n"scan_bg_2";
      default:
        return n"";
    };
  }

  public final static func GetWeaponTypeIcon(itemType: gamedataItemType) -> CName {
    switch itemType {
      case gamedataItemType.Wea_AssaultRifle:
        return n"UIIcon.WeaponTypeIcon_AssaultRifle";
      case gamedataItemType.Wea_Fists:
        return n"UIIcon.WeaponTypeIcon_Fists";
      case gamedataItemType.Wea_Hammer:
        return n"UIIcon.WeaponTypeIcon_Hammer";
      case gamedataItemType.Wea_Handgun:
        return n"UIIcon.WeaponTypeIcon_Handgun";
      case gamedataItemType.Wea_HeavyMachineGun:
        return n"UIIcon.WeaponTypeIcon_HeavyMachineGun";
      case gamedataItemType.Wea_Katana:
        return n"UIIcon.WeaponTypeIcon_Katana";
      case gamedataItemType.Wea_Knife:
        return n"UIIcon.WeaponTypeIcon_Knife";
      case gamedataItemType.Wea_LightMachineGun:
        return n"UIIcon.WeaponTypeIcon_LightMachineGun";
      case gamedataItemType.Wea_LongBlade:
        return n"UIIcon.WeaponTypeIcon_LongBlade";
      case gamedataItemType.Wea_Melee:
        return n"UIIcon.WeaponTypeIcon_Melee";
      case gamedataItemType.Wea_OneHandedClub:
        return n"UIIcon.WeaponTypeIcon_OneHandedClub";
      case gamedataItemType.Wea_PrecisionRifle:
        return n"UIIcon.WeaponTypeIcon_PrecisionRifle";
      case gamedataItemType.Wea_Revolver:
        return n"UIIcon.WeaponTypeIcon_Revolver";
      case gamedataItemType.Wea_Rifle:
        return n"UIIcon.WeaponTypeIcon_Rifle";
      case gamedataItemType.Wea_ShortBlade:
        return n"UIIcon.WeaponTypeIcon_ShortBlade";
      case gamedataItemType.Wea_Shotgun:
        return n"UIIcon.WeaponTypeIcon_Shotgun";
      case gamedataItemType.Wea_ShotgunDual:
        return n"UIIcon.WeaponTypeIcon_ShotgunDual";
      case gamedataItemType.Wea_SniperRifle:
        return n"UIIcon.WeaponTypeIcon_SniperRifle";
      case gamedataItemType.Wea_SubmachineGun:
        return n"UIIcon.WeaponTypeIcon_SubmachineGun";
      case gamedataItemType.Wea_TwoHandedClub:
        return n"UIIcon.WeaponTypeIcon_TwoHandedClub";
    };
    return n"UIIcon.WeaponTypeIcon_Default";
  }

  public final static func GetSlotShadowIcon(slotID: TweakDBID, itemType: gamedataItemType, equipmentArea: gamedataEquipmentArea) -> CName {
    switch slotID {
      case t"AttachmentSlots.Scope":
        return n"UIIcon.ItemShadow_Scope";
      case t"AttachmentSlots.PowerModule":
        return n"UIIcon.ItemShadow_Silencer";
      case t"AttachmentSlots.Magazine":
        return n"UIIcon.ItemShadow_Magazine";
      case t"AttachmentSlots.MeleeWeaponMod3":
      case t"AttachmentSlots.MeleeWeaponMod2":
      case t"AttachmentSlots.MeleeWeaponMod1":
      case t"AttachmentSlots.SmartWeaponMod1":
      case t"AttachmentSlots.TechWeaponMod1":
      case t"AttachmentSlots.PowerWeaponMod1":
      case t"AttachmentSlots.GenericWeaponMod4":
      case t"AttachmentSlots.GenericWeaponMod3":
      case t"AttachmentSlots.GenericWeaponMod2":
      case t"AttachmentSlots.GenericWeaponMod1":
        return n"UIIcon.ItemShadow_Mod";
      case t"AttachmentSlots.CyberdeckProgram8":
      case t"AttachmentSlots.CyberdeckProgram7":
      case t"AttachmentSlots.CyberdeckProgram6":
      case t"AttachmentSlots.CyberdeckProgram5":
      case t"AttachmentSlots.CyberdeckProgram4":
      case t"AttachmentSlots.CyberdeckProgram3":
      case t"AttachmentSlots.CyberdeckProgram2":
      case t"AttachmentSlots.CyberdeckProgram1":
        return n"UIIcon.ItemShadow_Program";
      case t"AttachmentSlots.ArmsCyberwareGeneralSlot":
      case t"AttachmentSlots.ProjectileLauncherWiring":
      case t"AttachmentSlots.ProjectileLauncherRound":
      case t"AttachmentSlots.NanoWiresBattery":
      case t"AttachmentSlots.NanoWiresCable":
      case t"AttachmentSlots.MantisBladesRotor":
      case t"AttachmentSlots.MantisBladesEdge":
      case t"AttachmentSlots.StrongArmsBattery":
      case t"AttachmentSlots.StrongArmsKnuckles":
      case t"AttachmentSlots.KiroshiOpticsSlot3":
      case t"AttachmentSlots.KiroshiOpticsSlot2":
      case t"AttachmentSlots.KiroshiOpticsSlot1":
      case t"AttachmentSlots.BerserkSlot3":
      case t"AttachmentSlots.BerserkSlot2":
      case t"AttachmentSlots.BerserkSlot1":
      case t"AttachmentSlots.SandevistanSlot3":
      case t"AttachmentSlots.SandevistanSlot2":
      case t"AttachmentSlots.SandevistanSlot1":
        return n"UIIcon.ItemShadow_Fragment";
      case t"AttachmentSlots.FootFabricEnhancer3":
      case t"AttachmentSlots.FootFabricEnhancer2":
      case t"AttachmentSlots.FootFabricEnhancer1":
      case t"AttachmentSlots.LegsFabricEnhancer3":
      case t"AttachmentSlots.LegsFabricEnhancer2":
      case t"AttachmentSlots.LegsFabricEnhancer1":
      case t"AttachmentSlots.OuterChestFabricEnhancer4":
      case t"AttachmentSlots.OuterChestFabricEnhancer3":
      case t"AttachmentSlots.OuterChestFabricEnhancer2":
      case t"AttachmentSlots.OuterChestFabricEnhancer1":
      case t"AttachmentSlots.InnerChestFabricEnhancer4":
      case t"AttachmentSlots.InnerChestFabricEnhancer3":
      case t"AttachmentSlots.InnerChestFabricEnhancer2":
      case t"AttachmentSlots.InnerChestFabricEnhancer1":
      case t"AttachmentSlots.FaceFabricEnhancer3":
      case t"AttachmentSlots.FaceFabricEnhancer2":
      case t"AttachmentSlots.FaceFabricEnhancer1":
      case t"AttachmentSlots.HeadFabricEnhancer3":
      case t"AttachmentSlots.HeadFabricEnhancer2":
      case t"AttachmentSlots.HeadFabricEnhancer1":
        return n"UIIcon.ItemShadow_Material";
    };
    return UIItemsHelper.GetSlotShadowIcon(itemType, equipmentArea);
  }

  public final static func GetSlotShadowIcon(itemType: gamedataItemType, equipmentArea: gamedataEquipmentArea) -> CName {
    switch itemType {
      case gamedataItemType.Prt_FabricEnhancer:
        return n"UIIcon.ItemShadow_Material";
      case gamedataItemType.Prt_Fragment:
        return n"UIIcon.ItemShadow_Fragment";
      case gamedataItemType.Prt_Magazine:
        return n"UIIcon.ItemShadow_Magazine";
      case gamedataItemType.Prt_Mod:
        return n"UIIcon.ItemShadow_Mod";
      case gamedataItemType.Prt_Muzzle:
        return n"UIIcon.ItemShadow_Silencer";
      case gamedataItemType.Prt_Program:
        return n"UIIcon.ItemShadow_Program";
      case gamedataItemType.Prt_Receiver:
        return n"UIIcon.ItemShadow_Receiver";
      case gamedataItemType.Prt_Scope:
        return n"UIIcon.ItemShadow_Scope";
      case gamedataItemType.Prt_ScopeRail:
        return n"UIIcon.ItemShadow_ScopeRail";
      case gamedataItemType.Prt_Stock:
        return n"UIIcon.ItemShadow_Stock";
      case gamedataItemType.Prt_TargetingSystem:
        return n"UIIcon.ItemShadow_TargetingSystem";
    };
    return UIItemsHelper.GetSlotShadowIcon(equipmentArea);
  }

  public final static func GetSlotShadowIcon(equipmentArea: gamedataEquipmentArea) -> CName {
    switch equipmentArea {
      case gamedataEquipmentArea.Consumable:
        return n"UIIcon.ItemShadow_Consumable";
      case gamedataEquipmentArea.AbilityCW:
        return n"UIIcon.ItemShadow_Cyberware";
      case gamedataEquipmentArea.Face:
        return n"UIIcon.ItemShadow_Face";
      case gamedataEquipmentArea.Feet:
        return n"UIIcon.ItemShadow_Feet";
      case gamedataEquipmentArea.Gadget:
      case gamedataEquipmentArea.QuickSlot:
        return n"UIIcon.ItemShadow_Grenade";
      case gamedataEquipmentArea.Head:
        return n"UIIcon.ItemShadow_Head";
      case gamedataEquipmentArea.InnerChest:
        return n"UIIcon.ItemShadow_InnerChest";
      case gamedataEquipmentArea.Legs:
        return n"UIIcon.ItemShadow_Legs";
      case gamedataEquipmentArea.OuterChest:
        return n"UIIcon.ItemShadow_OuterChest";
      case gamedataEquipmentArea.Outfit:
        return n"UIIcon.ItemShadow_Outfit";
      case gamedataEquipmentArea.Weapon:
        return n"UIIcon.ItemShadow_Weapon";
    };
    return n"UIIcon.ItemShadow_Default";
  }

  public final static func GetLootingtShadowIcon(slotID: TweakDBID, itemType: gamedataItemType, equipmentArea: gamedataEquipmentArea) -> CName {
    switch slotID {
      case t"AttachmentSlots.Scope":
        return n"UIIcon.LootingShadow_Scope";
      case t"AttachmentSlots.PowerModule":
        return n"UIIcon.LootingShadow_Silencer";
      case t"AttachmentSlots.Magazine":
        return n"UIIcon.LootingShadow_Magazine";
      case t"AttachmentSlots.MeleeWeaponMod3":
      case t"AttachmentSlots.MeleeWeaponMod2":
      case t"AttachmentSlots.MeleeWeaponMod1":
      case t"AttachmentSlots.SmartWeaponMod1":
      case t"AttachmentSlots.TechWeaponMod1":
      case t"AttachmentSlots.PowerWeaponMod1":
      case t"AttachmentSlots.GenericWeaponMod4":
      case t"AttachmentSlots.GenericWeaponMod3":
      case t"AttachmentSlots.GenericWeaponMod2":
      case t"AttachmentSlots.GenericWeaponMod1":
        return n"UIIcon.LootingShadow_Mod";
      case t"AttachmentSlots.CyberdeckProgram8":
      case t"AttachmentSlots.CyberdeckProgram7":
      case t"AttachmentSlots.CyberdeckProgram6":
      case t"AttachmentSlots.CyberdeckProgram5":
      case t"AttachmentSlots.CyberdeckProgram4":
      case t"AttachmentSlots.CyberdeckProgram3":
      case t"AttachmentSlots.CyberdeckProgram2":
      case t"AttachmentSlots.CyberdeckProgram1":
        return n"UIIcon.LootingShadow_Program";
      case t"AttachmentSlots.ArmsCyberwareGeneralSlot":
      case t"AttachmentSlots.ProjectileLauncherWiring":
      case t"AttachmentSlots.ProjectileLauncherRound":
      case t"AttachmentSlots.NanoWiresBattery":
      case t"AttachmentSlots.NanoWiresCable":
      case t"AttachmentSlots.MantisBladesRotor":
      case t"AttachmentSlots.MantisBladesEdge":
      case t"AttachmentSlots.StrongArmsBattery":
      case t"AttachmentSlots.StrongArmsKnuckles":
      case t"AttachmentSlots.KiroshiOpticsSlot3":
      case t"AttachmentSlots.KiroshiOpticsSlot2":
      case t"AttachmentSlots.KiroshiOpticsSlot1":
      case t"AttachmentSlots.BerserkSlot3":
      case t"AttachmentSlots.BerserkSlot2":
      case t"AttachmentSlots.BerserkSlot1":
      case t"AttachmentSlots.SandevistanSlot3":
      case t"AttachmentSlots.SandevistanSlot2":
      case t"AttachmentSlots.SandevistanSlot1":
        return n"UIIcon.LootingShadow_Fragment";
      case t"AttachmentSlots.FootFabricEnhancer3":
      case t"AttachmentSlots.FootFabricEnhancer2":
      case t"AttachmentSlots.FootFabricEnhancer1":
      case t"AttachmentSlots.LegsFabricEnhancer3":
      case t"AttachmentSlots.LegsFabricEnhancer2":
      case t"AttachmentSlots.LegsFabricEnhancer1":
      case t"AttachmentSlots.OuterChestFabricEnhancer4":
      case t"AttachmentSlots.OuterChestFabricEnhancer3":
      case t"AttachmentSlots.OuterChestFabricEnhancer2":
      case t"AttachmentSlots.OuterChestFabricEnhancer1":
      case t"AttachmentSlots.InnerChestFabricEnhancer4":
      case t"AttachmentSlots.InnerChestFabricEnhancer3":
      case t"AttachmentSlots.InnerChestFabricEnhancer2":
      case t"AttachmentSlots.InnerChestFabricEnhancer1":
      case t"AttachmentSlots.FaceFabricEnhancer3":
      case t"AttachmentSlots.FaceFabricEnhancer2":
      case t"AttachmentSlots.FaceFabricEnhancer1":
      case t"AttachmentSlots.HeadFabricEnhancer3":
      case t"AttachmentSlots.HeadFabricEnhancer2":
      case t"AttachmentSlots.HeadFabricEnhancer1":
        return n"UIIcon.LootingShadow_Material";
    };
    return UIItemsHelper.GetLootingtShadowIcon(itemType, equipmentArea);
  }

  public final static func GetLootingtShadowIcon(itemType: gamedataItemType, equipmentArea: gamedataEquipmentArea) -> CName {
    switch itemType {
      case gamedataItemType.Prt_FabricEnhancer:
        return n"UIIcon.LootingShadow_Material";
      case gamedataItemType.Prt_Fragment:
        return n"UIIcon.LootingShadow_Fragment";
      case gamedataItemType.Prt_Magazine:
        return n"UIIcon.LootingShadow_Magazine";
      case gamedataItemType.Prt_Mod:
        return n"UIIcon.LootingShadow_Mod";
      case gamedataItemType.Prt_Muzzle:
        return n"UIIcon.LootingShadow_Silencer";
      case gamedataItemType.Prt_Program:
        return n"UIIcon.LootingShadow_Program";
      case gamedataItemType.Prt_Receiver:
        return n"UIIcon.Lootinghadow_Receiver";
      case gamedataItemType.Prt_Scope:
        return n"UIIcon.LootingShadow_Scope";
      case gamedataItemType.Prt_ScopeRail:
        return n"UIIcon.LootingShadow_ScopeRail";
      case gamedataItemType.Prt_Stock:
        return n"UIIcon.LootingShadow_Stock";
      case gamedataItemType.Prt_TargetingSystem:
        return n"UIIcon.LootingShadow_TargetingSystem";
      case gamedataItemType.Con_Inhaler:
        return n"UIIcon.LootingShadow_Inhaler";
      case gamedataItemType.Con_Injector:
        return n"UIIcon.LootingShadow_Injector";
      case gamedataItemType.Gen_Readable:
        return n"UIIcon.LootingShadow_Shard";
      case gamedataItemType.Gen_Junk:
        return n"UIIcon.LootingShadow_Junk";
      case gamedataItemType.Wea_AssaultRifle:
        return n"UIIcon.WeaponTypeIcon_AssaultRifle";
      case gamedataItemType.Wea_Fists:
        return n"UIIcon.WeaponTypeIcon_Fists";
      case gamedataItemType.Wea_Hammer:
        return n"UIIcon.WeaponTypeIcon_Hammer";
      case gamedataItemType.Wea_Handgun:
        return n"UIIcon.WeaponTypeIcon_Handgun";
      case gamedataItemType.Wea_HeavyMachineGun:
        return n"UIIcon.WeaponTypeIcon_HeavyMachineGun";
      case gamedataItemType.Wea_Katana:
        return n"UIIcon.WeaponTypeIcon_Katana";
      case gamedataItemType.Wea_Knife:
        return n"UIIcon.WeaponTypeIcon_Knife";
      case gamedataItemType.Wea_LightMachineGun:
        return n"UIIcon.WeaponTypeIcon_LightMachineGun";
      case gamedataItemType.Wea_LongBlade:
        return n"UIIcon.WeaponTypeIcon_LongBlade";
      case gamedataItemType.Wea_Melee:
        return n"UIIcon.WeaponTypeIcon_Melee";
      case gamedataItemType.Wea_OneHandedClub:
        return n"UIIcon.WeaponTypeIcon_OneHandedClub";
      case gamedataItemType.Wea_PrecisionRifle:
        return n"UIIcon.WeaponTypeIcon_PrecisionRifle";
      case gamedataItemType.Wea_Revolver:
        return n"UIIcon.WeaponTypeIcon_Revolver";
      case gamedataItemType.Wea_Rifle:
        return n"UIIcon.WeaponTypeIcon_Rifle";
      case gamedataItemType.Wea_ShortBlade:
        return n"UIIcon.WeaponTypeIcon_ShortBlade";
      case gamedataItemType.Wea_Shotgun:
        return n"UIIcon.WeaponTypeIcon_Shotgun";
      case gamedataItemType.Wea_ShotgunDual:
        return n"UIIcon.WeaponTypeIcon_ShotgunDual";
      case gamedataItemType.Wea_SniperRifle:
        return n"UIIcon.WeaponTypeIcon_SniperRifle";
      case gamedataItemType.Wea_SubmachineGun:
        return n"UIIcon.WeaponTypeIcon_SubmachineGun";
      case gamedataItemType.Wea_TwoHandedClub:
        return n"UIIcon.WeaponTypeIcon_TwoHandedClub";
    };
    return UIItemsHelper.GetLootingtShadowIcon(equipmentArea);
  }

  public final static func GetLootingtShadowIcon(equipmentArea: gamedataEquipmentArea) -> CName {
    switch equipmentArea {
      case gamedataEquipmentArea.Consumable:
        return n"UIIcon.LootingShadow_Consumable";
      case gamedataEquipmentArea.AbilityCW:
        return n"UIIcon.LootingShadow_Cyberware";
      case gamedataEquipmentArea.Face:
        return n"UIIcon.LootingShadow_Face";
      case gamedataEquipmentArea.Feet:
        return n"UIIcon.LootingShadow_Feet";
      case gamedataEquipmentArea.Gadget:
      case gamedataEquipmentArea.QuickSlot:
        return n"UIIcon.LootingShadow_Grenade";
      case gamedataEquipmentArea.Head:
        return n"UIIcon.LootingShadow_Head";
      case gamedataEquipmentArea.InnerChest:
        return n"UIIcon.LootingShadow_InnerChest";
      case gamedataEquipmentArea.Legs:
        return n"UIIcon.LootingShadow_Legs";
      case gamedataEquipmentArea.OuterChest:
        return n"UIIcon.LootingShadow_OuterChest";
      case gamedataEquipmentArea.Outfit:
        return n"UIIcon.LootingShadow_Outfit";
      case gamedataEquipmentArea.Weapon:
        return n"UIIcon.LootingShadow_Weapon";
    };
    return n"UIIcon.LootingShadow_Default";
  }

  public final static func GetSlotName(slotID: TweakDBID, itemType: gamedataItemType, equipmentArea: gamedataEquipmentArea) -> String {
    switch slotID {
      case t"AttachmentSlots.Scope":
        return "Gameplay-Items-Item Type-Prt_Scope";
      case t"AttachmentSlots.PowerModule":
        return "Gameplay-Items-Item Type-Prt_Muzzle";
      case t"AttachmentSlots.Magazine":
        return "Gameplay-Items-Item Type-Prt_Magazine";
      case t"AttachmentSlots.MeleeWeaponMod3":
      case t"AttachmentSlots.MeleeWeaponMod2":
      case t"AttachmentSlots.MeleeWeaponMod1":
      case t"AttachmentSlots.SmartWeaponMod3":
      case t"AttachmentSlots.SmartWeaponMod2":
      case t"AttachmentSlots.SmartWeaponMod1":
      case t"AttachmentSlots.TechWeaponMod3":
      case t"AttachmentSlots.TechWeaponMod2":
      case t"AttachmentSlots.TechWeaponMod1":
      case t"AttachmentSlots.PowerWeaponMod3":
      case t"AttachmentSlots.PowerWeaponMod2":
      case t"AttachmentSlots.PowerWeaponMod1":
      case t"AttachmentSlots.GenericWeaponMod4":
      case t"AttachmentSlots.GenericWeaponMod3":
      case t"AttachmentSlots.GenericWeaponMod2":
      case t"AttachmentSlots.GenericWeaponMod1":
        return "Gameplay-Items-Item Type-Prt_Mod";
      case t"AttachmentSlots.CyberdeckProgram8":
      case t"AttachmentSlots.CyberdeckProgram7":
      case t"AttachmentSlots.CyberdeckProgram6":
      case t"AttachmentSlots.CyberdeckProgram5":
      case t"AttachmentSlots.CyberdeckProgram4":
      case t"AttachmentSlots.CyberdeckProgram3":
      case t"AttachmentSlots.CyberdeckProgram2":
      case t"AttachmentSlots.CyberdeckProgram1":
        return "Gameplay-Items-Item Type-Prt_Program";
      case t"AttachmentSlots.ArmsCyberwareGeneralSlot":
      case t"AttachmentSlots.ProjectileLauncherWiring":
      case t"AttachmentSlots.ProjectileLauncherRound":
      case t"AttachmentSlots.NanoWiresBattery":
      case t"AttachmentSlots.NanoWiresCable":
      case t"AttachmentSlots.MantisBladesRotor":
      case t"AttachmentSlots.MantisBladesEdge":
      case t"AttachmentSlots.StrongArmsBattery":
      case t"AttachmentSlots.StrongArmsKnuckles":
      case t"AttachmentSlots.KiroshiOpticsSlot3":
      case t"AttachmentSlots.KiroshiOpticsSlot2":
      case t"AttachmentSlots.KiroshiOpticsSlot1":
      case t"AttachmentSlots.BerserkSlot3":
      case t"AttachmentSlots.BerserkSlot2":
      case t"AttachmentSlots.BerserkSlot1":
      case t"AttachmentSlots.SandevistanSlot3":
      case t"AttachmentSlots.SandevistanSlot2":
      case t"AttachmentSlots.SandevistanSlot1":
        return "Gameplay-Items-Item Type-Prt_Fragment";
      case t"AttachmentSlots.FootFabricEnhancer3":
      case t"AttachmentSlots.FootFabricEnhancer2":
      case t"AttachmentSlots.FootFabricEnhancer1":
      case t"AttachmentSlots.LegsFabricEnhancer3":
      case t"AttachmentSlots.LegsFabricEnhancer2":
      case t"AttachmentSlots.LegsFabricEnhancer1":
      case t"AttachmentSlots.OuterChestFabricEnhancer4":
      case t"AttachmentSlots.OuterChestFabricEnhancer3":
      case t"AttachmentSlots.OuterChestFabricEnhancer2":
      case t"AttachmentSlots.OuterChestFabricEnhancer1":
      case t"AttachmentSlots.InnerChestFabricEnhancer4":
      case t"AttachmentSlots.InnerChestFabricEnhancer3":
      case t"AttachmentSlots.InnerChestFabricEnhancer2":
      case t"AttachmentSlots.InnerChestFabricEnhancer1":
      case t"AttachmentSlots.FaceFabricEnhancer3":
      case t"AttachmentSlots.FaceFabricEnhancer2":
      case t"AttachmentSlots.FaceFabricEnhancer1":
      case t"AttachmentSlots.HeadFabricEnhancer3":
      case t"AttachmentSlots.HeadFabricEnhancer2":
      case t"AttachmentSlots.HeadFabricEnhancer1":
        return "Gameplay-Items-Item Type-Prt_FabricEnhancer";
    };
    return UIItemsHelper.GetSlotName(itemType, equipmentArea);
  }

  public final static func GetSlotName(itemType: gamedataItemType, equipmentArea: gamedataEquipmentArea) -> String {
    switch itemType {
      case gamedataItemType.Prt_Capacitor:
        return "Gameplay-Items-Item Type-Prt_Capacitor";
      case gamedataItemType.Prt_FabricEnhancer:
        return "Gameplay-Items-Item Type-Prt_FabricEnhancer";
      case gamedataItemType.Prt_Fragment:
        return "Gameplay-Items-Item Type-Prt_Fragment";
      case gamedataItemType.Prt_Magazine:
        return "Gameplay-Items-Item Type-Prt_Magazine";
      case gamedataItemType.Prt_Mod:
        return "Gameplay-Items-Item Type-Prt_Mod";
      case gamedataItemType.Prt_Muzzle:
        return "Gameplay-Items-Item Type-Prt_Muzzle";
      case gamedataItemType.Prt_Program:
        return "Gameplay-Items-Item Type-Prt_Program";
      case gamedataItemType.Prt_Receiver:
        return "Gameplay-Items-Item Type-Prt_Receiver";
      case gamedataItemType.Prt_Scope:
        return "Gameplay-Items-Item Type-Prt_Scope";
      case gamedataItemType.Prt_ScopeRail:
        return "Gameplay-Items-Item Type-Prt_ScopeRail";
      case gamedataItemType.Prt_Stock:
        return "Gameplay-Items-Item Type-Prt_Stock";
      case gamedataItemType.Prt_TargetingSystem:
        return "Gameplay-Items-Item Type-Prt_TargetingSystem";
    };
    return UIItemsHelper.GetSlotName(equipmentArea);
  }

  public final static func GetSlotName(equipmentArea: gamedataEquipmentArea) -> String {
    switch equipmentArea {
      case gamedataEquipmentArea.Consumable:
        return "UI-Inventory-Tooltips-ConsumablesDescription";
      case gamedataEquipmentArea.AbilityCW:
        return "UI-Inventory-Tooltips-CyberwareDescription";
      case gamedataEquipmentArea.Face:
        return "UI-Inventory-Tooltips-FaceDescription";
      case gamedataEquipmentArea.Feet:
        return "UI-Inventory-Tooltips-FeetDescription";
      case gamedataEquipmentArea.Gadget:
      case gamedataEquipmentArea.QuickSlot:
        return "UI-Inventory-Tooltips-GadgetsDescription";
      case gamedataEquipmentArea.Head:
        return "UI-Inventory-Tooltips-HeadDescription";
      case gamedataEquipmentArea.InnerChest:
        return "UI-Inventory-Tooltips-InnerChestDescription";
      case gamedataEquipmentArea.Legs:
        return "UI-Inventory-Tooltips-LegsDescription";
      case gamedataEquipmentArea.OuterChest:
        return "UI-Inventory-Tooltips-OuterChestDescription";
      case gamedataEquipmentArea.Outfit:
        return "UI-Inventory-Tooltips-OutfitDescription";
      case gamedataEquipmentArea.Weapon:
        return "UI-Inventory-Tooltips-WeaponDescription";
    };
    return "";
  }

  public final static func GetItemTypeKey(itemData: wref<gameItemData>, equipmentArea: gamedataEquipmentArea, itemID: TweakDBID, itemType: gamedataItemType, weaponEvolutionType: gamedataWeaponEvolution) -> String {
    if itemData.HasTag(n"Recipe") {
      return "Gameplay-Crafting-GenericRecipe";
    };
    return UIItemsHelper.GetItemTypeKey(equipmentArea, itemID, itemType, weaponEvolutionType);
  }

  public final static func GetItemTypeKey(equipmentArea: gamedataEquipmentArea, itemID: TweakDBID, itemType: gamedataItemType, weaponEvolutionType: gamedataWeaponEvolution) -> String {
    switch equipmentArea {
      case gamedataEquipmentArea.SystemReplacementCW:
      case gamedataEquipmentArea.NervousSystemCW:
      case gamedataEquipmentArea.MusculoskeletalSystemCW:
      case gamedataEquipmentArea.LegsCW:
      case gamedataEquipmentArea.IntegumentarySystemCW:
      case gamedataEquipmentArea.ImmuneSystemCW:
      case gamedataEquipmentArea.HandsCW:
      case gamedataEquipmentArea.FrontalCortexCW:
      case gamedataEquipmentArea.EyesCW:
      case gamedataEquipmentArea.CardiovascularSystemCW:
      case gamedataEquipmentArea.ArmsCW:
      case gamedataEquipmentArea.AbilityCW:
        return "UI-Inventory-Tooltips-CyberwareDescription";
    };
    return UIItemsHelper.GetItemTypeKey(itemID, itemType, weaponEvolutionType);
  }

  public final static func GetItemTypeKey(itemID: TweakDBID, itemType: gamedataItemType, weaponEvolutionType: gamedataWeaponEvolution) -> String {
    switch itemID {
      case t"Items.money":
        return "UI-ItemLabel-Money";
    };
    return UIItemsHelper.GetItemTypeKey(itemType, weaponEvolutionType);
  }

  public final static func GetItemTypeKey(itemType: gamedataItemType, weaponEvolutionType: gamedataWeaponEvolution) -> String {
    let keySuffix: String;
    switch weaponEvolutionType {
      case gamedataWeaponEvolution.Power:
        keySuffix = "_Power";
        break;
      case gamedataWeaponEvolution.Smart:
        keySuffix = "_Smart";
        break;
      case gamedataWeaponEvolution.Tech:
        keySuffix = "_Tech";
    };
    if IsStringValid(keySuffix) {
      return UIItemsHelper.GetEvolutionWeaponType(itemType) + keySuffix;
    };
    return UIItemsHelper.GetItemTypeKey(itemType);
  }

  public final static func GetEvolutionWeaponType(itemType: gamedataItemType) -> String {
    switch itemType {
      case gamedataItemType.Wea_AssaultRifle:
        return "UI-WeaponItemType-Wea_AssaultRifle";
      case gamedataItemType.Wea_Fists:
        return "UI-WeaponItemType-Wea_Fists";
      case gamedataItemType.Wea_Hammer:
        return "UI-WeaponItemType-Wea_Hammer";
      case gamedataItemType.Wea_Handgun:
        return "UI-WeaponItemType-Wea_Handgun";
      case gamedataItemType.Wea_HeavyMachineGun:
        return "UI-WeaponItemType-Wea_HeavyMachineGun";
      case gamedataItemType.Wea_Katana:
        return "UI-WeaponItemType-Wea_Katana";
      case gamedataItemType.Wea_Knife:
        return "UI-WeaponItemType-Wea_Knife";
      case gamedataItemType.Wea_LightMachineGun:
        return "UI-WeaponItemType-Wea_LightMachineGun";
      case gamedataItemType.Wea_LongBlade:
        return "UI-WeaponItemType-Wea_LongBlade";
      case gamedataItemType.Wea_Melee:
        return "UI-WeaponItemType-Wea_Melee";
      case gamedataItemType.Wea_OneHandedClub:
        return "UI-WeaponItemType-Wea_OneHandedClub";
      case gamedataItemType.Wea_PrecisionRifle:
        return "UI-WeaponItemType-Wea_PrecisionRifle";
      case gamedataItemType.Wea_Revolver:
        return "UI-WeaponItemType-Wea_Revolver";
      case gamedataItemType.Wea_Rifle:
        return "UI-WeaponItemType-Wea_Rifle";
      case gamedataItemType.Wea_ShortBlade:
        return "UI-WeaponItemType-Wea_ShortBlade";
      case gamedataItemType.Wea_Shotgun:
        return "UI-WeaponItemType-Wea_Shotgun";
      case gamedataItemType.Wea_ShotgunDual:
        return "UI-WeaponItemType-Wea_ShotgunDual";
      case gamedataItemType.Wea_SniperRifle:
        return "UI-WeaponItemType-Wea_SniperRifle";
      case gamedataItemType.Wea_SubmachineGun:
        return "UI-WeaponItemType-Wea_SubmachineGun";
      case gamedataItemType.Wea_TwoHandedClub:
        return "UI-WeaponItemType-Wea_TwoHandedClub";
    };
    return "MISSING KEY";
  }

  public final static func GetItemTypeKey(itemType: gamedataItemType) -> String {
    switch itemType {
      case gamedataItemType.Clo_Face:
        return "Gameplay-Items-Item Type-Clo_Face";
      case gamedataItemType.Clo_Feet:
        return "Gameplay-Items-Item Type-Clo_Feet";
      case gamedataItemType.Clo_Head:
        return "Gameplay-Items-Item Type-Clo_Head";
      case gamedataItemType.Clo_InnerChest:
        return "Gameplay-Items-Item Type-Clo_InnerChest";
      case gamedataItemType.Clo_Legs:
        return "Gameplay-Items-Item Type-Clo_Legs";
      case gamedataItemType.Clo_OuterChest:
        return "Gameplay-Items-Item Type-Clo_OuterChest";
      case gamedataItemType.Con_Ammo:
        return "Gameplay-RPG-Items-Types-Con_Ammo";
      case gamedataItemType.Con_Edible:
        return "Gameplay-Items-Item Type-Con_Edible";
      case gamedataItemType.Con_Inhaler:
        return "Gameplay-Items-Item Type-Con_Inhaler";
      case gamedataItemType.Con_Injector:
        return "Gameplay-Items-Item Type-Con_Injector";
      case gamedataItemType.Con_LongLasting:
        return "Gameplay-Items-Item Type-Con_LongLasting";
      case gamedataItemType.Con_Skillbook:
        return "Gameplay-Items-Item Type-Con_Skillbook";
      case gamedataItemType.Cyb_Ability:
        return "Gameplay-RPG-Items-Types-Cyb_Ability";
      case gamedataItemType.Cyb_Launcher:
        return "Gameplay-Items-Item Type-Cyb_Launcher";
      case gamedataItemType.Cyb_MantisBlades:
        return "Gameplay-Items-Item Type-Cyb_MantisBlades";
      case gamedataItemType.Cyb_NanoWires:
        return "Gameplay-Items-Item Type-Cyb_NanoWires";
      case gamedataItemType.Cyb_StrongArms:
        return "Gameplay-Items-Item Type-Cyb_StrongArms";
      case gamedataItemType.Fla_Launcher:
        return "MISSING KEY";
      case gamedataItemType.Fla_Rifle:
        return "MISSING KEY";
      case gamedataItemType.Fla_Shock:
        return "MISSING KEY";
      case gamedataItemType.Fla_Support:
        return "MISSING KEY";
      case gamedataItemType.Gad_Grenade:
        return "Gameplay-RPG-Items-Types-Gad_Grenade";
      case gamedataItemType.Gen_CraftingMaterial:
        return "Gameplay-Items-Item Type-Gen_CraftingMaterial";
      case gamedataItemType.Gen_Junk:
        return "Gameplay-Items-Item Type-Gen_Junk";
      case gamedataItemType.Gen_Keycard:
        return "Gameplay-Items-Item Type-Gen_Keycard";
      case gamedataItemType.Gen_Misc:
        return "Gameplay-Items-Item Type-Gen_Misc";
      case gamedataItemType.Gen_Readable:
        return "Gameplay-Items-Item Type-Gen_Readable";
      case gamedataItemType.GrenadeDelivery:
        return "Gameplay-Items-Item Type-Prt_DeliveryMethod";
      case gamedataItemType.Grenade_Core:
        return "Gameplay-Items-Item Type-Prt_GrenadeCore";
      case gamedataItemType.Prt_Capacitor:
        return "Gameplay-Items-Item Type-Prt_Capacitor";
      case gamedataItemType.Prt_FabricEnhancer:
        return "Gameplay-Items-Item Type-Prt_FabricEnhancer";
      case gamedataItemType.Prt_Fragment:
        return "Gameplay-Items-Item Type-Prt_Fragment";
      case gamedataItemType.Prt_Magazine:
        return "Gameplay-Items-Item Type-Prt_Magazine";
      case gamedataItemType.Prt_Mod:
        return "Gameplay-Items-Item Type-Prt_Mod";
      case gamedataItemType.Prt_Muzzle:
        return "Gameplay-Items-Item Type-Prt_Muzzle";
      case gamedataItemType.Prt_Program:
        return "Gameplay-Items-Item Type-Prt_Program";
      case gamedataItemType.Prt_Receiver:
        return "Gameplay-Items-Item Type-Prt_Receiver";
      case gamedataItemType.Prt_Scope:
        return "Gameplay-Items-Item Type-Prt_Scope";
      case gamedataItemType.Prt_ScopeRail:
        return "Gameplay-Items-Item Type-Prt_ScopeRail";
      case gamedataItemType.Prt_Stock:
        return "Gameplay-Items-Item Type-Prt_Stock";
      case gamedataItemType.Prt_TargetingSystem:
        return "Gameplay-Items-Item Type-Prt_TargetingSystem";
      case gamedataItemType.Wea_AssaultRifle:
        return "Gameplay-RPG-Items-Types-Wea_AssaultRifle";
      case gamedataItemType.Wea_Fists:
        return "Gameplay-RPG-Items-Types-Wea_Fists";
      case gamedataItemType.Wea_Hammer:
        return "Gameplay-RPG-Items-Types-Wea_Hammer";
      case gamedataItemType.Wea_Handgun:
        return "Gameplay-RPG-Items-Types-Wea_Handgun";
      case gamedataItemType.Wea_HeavyMachineGun:
        return "Gameplay-Items-Item Type-Wea_HeavyMachineGun";
      case gamedataItemType.Wea_Katana:
        return "Gameplay-RPG-Items-Types-Wea_Katana";
      case gamedataItemType.Wea_Knife:
        return "Gameplay-RPG-Items-Types-Wea_Knife";
      case gamedataItemType.Wea_LightMachineGun:
        return "Gameplay-RPG-Items-Types-Wea_LightMachineGun";
      case gamedataItemType.Wea_LongBlade:
        return "Gameplay-RPG-Items-Types-Wea_LongBlade";
      case gamedataItemType.Wea_Melee:
        return "Gameplay-RPG-Items-Types-Wea_Melee";
      case gamedataItemType.Wea_OneHandedClub:
        return "Gameplay-RPG-Items-Types-Wea_OneHandedClub";
      case gamedataItemType.Wea_PrecisionRifle:
        return "Gameplay-RPG-Items-Types-Wea_PrecisionRifle";
      case gamedataItemType.Wea_Revolver:
        return "Gameplay-RPG-Items-Types-Wea_Revolver";
      case gamedataItemType.Wea_Rifle:
        return "Gameplay-RPG-Items-Types-Wea_Rifle";
      case gamedataItemType.Wea_ShortBlade:
        return "Gameplay-RPG-Items-Types-Wea_ShortBlade";
      case gamedataItemType.Wea_Shotgun:
        return "Gameplay-RPG-Items-Types-Wea_Shotgun";
      case gamedataItemType.Wea_ShotgunDual:
        return "Gameplay-RPG-Items-Types-Wea_ShotgunDual";
      case gamedataItemType.Wea_SniperRifle:
        return "Gameplay-RPG-Items-Types-Wea_SniperRifle";
      case gamedataItemType.Wea_SubmachineGun:
        return "Gameplay-RPG-Items-Types-Wea_SubmachineGun";
      case gamedataItemType.Wea_TwoHandedClub:
        return "Gameplay-RPG-Items-Types-Wea_TwoHandedClub";
    };
    return "";
  }

  public final static func GetEmptySlotName(slotId: TweakDBID) -> String {
    switch slotId {
      case t"AttachmentSlots.GenericWeaponMod4":
      case t"AttachmentSlots.GenericWeaponMod3":
      case t"AttachmentSlots.GenericWeaponMod2":
      case t"AttachmentSlots.GenericWeaponMod1":
        return "UI-Labels-EmptyModSlot";
      case t"AttachmentSlots.MeleeWeaponMod3":
      case t"AttachmentSlots.MeleeWeaponMod2":
      case t"AttachmentSlots.MeleeWeaponMod1":
        return "UI-Labels-EmptyMeleeModSlot";
      case t"AttachmentSlots.Scope":
        return "UI-Labels-EmptyScopeSlot";
      case t"AttachmentSlots.PowerModule":
        return "UI-Labels-EmptyMuzzleSlot";
      case t"AttachmentSlots.FootFabricEnhancer3":
      case t"AttachmentSlots.FootFabricEnhancer2":
      case t"AttachmentSlots.FootFabricEnhancer1":
      case t"AttachmentSlots.LegsFabricEnhancer3":
      case t"AttachmentSlots.LegsFabricEnhancer2":
      case t"AttachmentSlots.LegsFabricEnhancer1":
      case t"AttachmentSlots.OuterChestFabricEnhancer4":
      case t"AttachmentSlots.OuterChestFabricEnhancer3":
      case t"AttachmentSlots.OuterChestFabricEnhancer2":
      case t"AttachmentSlots.OuterChestFabricEnhancer1":
      case t"AttachmentSlots.InnerChestFabricEnhancer4":
      case t"AttachmentSlots.InnerChestFabricEnhancer3":
      case t"AttachmentSlots.InnerChestFabricEnhancer2":
      case t"AttachmentSlots.InnerChestFabricEnhancer1":
      case t"AttachmentSlots.FaceFabricEnhancer3":
      case t"AttachmentSlots.FaceFabricEnhancer2":
      case t"AttachmentSlots.FaceFabricEnhancer1":
      case t"AttachmentSlots.HeadFabricEnhancer3":
      case t"AttachmentSlots.HeadFabricEnhancer2":
      case t"AttachmentSlots.HeadFabricEnhancer1":
        return "UI-Labels-EmptyClothingModSlot";
      case t"AttachmentSlots.CyberdeckProgram8":
      case t"AttachmentSlots.CyberdeckProgram7":
      case t"AttachmentSlots.CyberdeckProgram6":
      case t"AttachmentSlots.CyberdeckProgram5":
      case t"AttachmentSlots.CyberdeckProgram4":
      case t"AttachmentSlots.CyberdeckProgram3":
      case t"AttachmentSlots.CyberdeckProgram2":
      case t"AttachmentSlots.CyberdeckProgram1":
        return "UI-Labels-EmptyProgramSlot";
      case t"AttachmentSlots.KiroshiOpticsSlot3":
      case t"AttachmentSlots.KiroshiOpticsSlot2":
      case t"AttachmentSlots.KiroshiOpticsSlot1":
      case t"AttachmentSlots.KERSSlot3":
      case t"AttachmentSlots.KERSSlot2":
      case t"AttachmentSlots.KERSSlot1":
      case t"AttachmentSlots.BerserkSlot3":
      case t"AttachmentSlots.BerserkSlot2":
      case t"AttachmentSlots.BerserkSlot1":
      case t"AttachmentSlots.SandevistanSlot3":
      case t"AttachmentSlots.SandevistanSlot2":
      case t"AttachmentSlots.SandevistanSlot1":
        return "UI-Labels-EmptyCyberwareModSlot";
    };
    return "UI-Labels-EmptySlot";
  }

  public final static func GetTooltipItemName(data: ref<InventoryTooltipData>) -> String {
    let id: TweakDBID = ItemID.GetTDBID(InventoryItemData.GetID(data.inventoryItemData));
    let itemData: wref<gameItemData> = InventoryItemData.GetGameItemData(data.inventoryItemData);
    return UIItemsHelper.GetTooltipItemName(id, itemData, data.itemName);
  }

  public final static func GetTooltipItemName(itemID: TweakDBID, itemData: wref<gameItemData>, fallbackName: String) -> String {
    if itemData.HasTag(n"Shard") {
      return fallbackName;
    };
    return UIItemsHelper.GetItemName(itemID, itemData);
  }

  public final static func GetItemName(itemData: InventoryItemData) -> String {
    return UIItemsHelper.GetItemName(ItemID.GetTDBID(InventoryItemData.GetID(itemData)), InventoryItemData.GetGameItemData(itemData));
  }

  public final static func GetItemName(itemID: TweakDBID, itemData: wref<gameItemData>) -> String {
    return UIItemsHelper.GetItemName(TweakDBInterface.GetItemRecord(itemID), itemData);
  }

  public final static func GetItemName(itemRecord: ref<Item_Record>, itemData: wref<gameItemData>) -> String {
    let craftingResult: wref<CraftingResult_Record>;
    let itemName: String;
    let recipeRecord: wref<ItemRecipe_Record> = itemRecord as ItemRecipe_Record;
    if IsDefined(recipeRecord) {
      craftingResult = recipeRecord.CraftingResult();
      if IsDefined(craftingResult) {
        itemName = GetLocalizedItemNameByCName(craftingResult.Item().DisplayName());
      } else {
        itemName = GetLocalizedItemNameByCName(itemRecord.DisplayName());
      };
    } else {
      if IsDefined(itemRecord) {
        itemName = GetLocalizedItemNameByCName(itemRecord.DisplayName());
      };
    };
    if IsDefined(itemData) && itemData.HasTag(n"Recipe") {
      itemName = GetLocalizedText("Gameplay-Crafting-GenericRecipe") + " " + itemName;
    };
    return itemName;
  }
}
