
public struct QuickSlotCommand {

  @default(QuickSlotCommand, QuickSlotActionType.Undefined)
  public let ActionType: QuickSlotActionType;

  @default(QuickSlotCommand, true)
  public let IsSlotUnlocked: Bool;

  public let IsLocked: Bool;

  public let AtlasPath: CName;

  public let IconName: CName;

  public let MaxTier: Int32;

  public let VehicleState: Int32;

  public let ItemId: ItemID;

  public let Title: String;

  public let Type: String;

  public let Description: String;

  public let IsEquipped: Bool;

  public let intData: Int32;

  public let playerVehicleData: PlayerVehicle;

  @default(QuickSlotCommand, QuickSlotItemType.Undefined)
  public let itemType: QuickSlotItemType;

  public let equipType: gamedataEquipmentArea;

  public let slotIndex: Int32;

  public let interactiveAction: ref<DeviceAction>;

  public let interactiveActionOwner: EntityID;

  public final static func IsEmpty(self: QuickSlotCommand) -> Bool {
    let empty: QuickSlotCommand;
    if Equals(empty.ActionType, self.ActionType) && Equals(empty.IsSlotUnlocked, self.IsSlotUnlocked) && Equals(empty.IsLocked, self.IsLocked) && Equals(empty.IsSlotUnlocked, self.IsSlotUnlocked) && Equals(empty.AtlasPath, self.AtlasPath) && Equals(empty.IconName, self.IconName) && empty.MaxTier == self.MaxTier && empty.VehicleState == self.VehicleState && Equals(empty.Title, self.Title) && Equals(empty.Type, self.Type) && Equals(empty.Description, self.Description) && Equals(empty.IsEquipped, self.IsEquipped) && empty.intData == self.intData && empty.slotIndex == self.slotIndex {
      return true;
    };
    return false;
  }
}

public class QuickSlotsManagerPS extends GameComponentPS {

  @default(QuickSlotsManagerPS, gamedataVehicleType.Car)
  private persistent let m_activeVehicleType: gamedataVehicleType;

  public final func SetActiveType(type: gamedataVehicleType) -> Void {
    this.m_activeVehicleType = type;
  }

  public final func GetActiveType() -> gamedataVehicleType {
    return this.m_activeVehicleType;
  }
}

public class QuickSlotsManager extends ScriptableComponent {

  private let m_Player: wref<PlayerPuppet>;

  private let m_QuickSlotsBB: wref<IBlackboard>;

  private let m_IsPlayerInCar: Bool;

  private let m_PlayerVehicleID: EntityID;

  private let m_QuickDpadCommands: array<QuickSlotCommand>;

  private let m_QuickDpadCommands_Vehicle: array<QuickSlotCommand>;

  private let m_DefaultHoldCommands: array<QuickSlotCommand>;

  private let m_DefaultHoldCommands_Vehicle: array<QuickSlotCommand>;

  @default(QuickSlotsManager, 8)
  private let m_NumberOfItemsPerWheel: Int32;

  private let m_QuickKeyboardCommands: array<QuickSlotCommand>;

  private let m_QuickKeyboardCommands_Vehicle: array<QuickSlotCommand>;

  private let m_lastPressAndHoldBtn: ref<QuickSlotButtonHoldEndEvent>;

  private let m_WheelList_Vehicles: array<QuickSlotCommand>;

  private let m_currentWheelItem: QuickSlotCommand;

  private let m_currentWeaponWheelItem: QuickSlotCommand;

  private let m_currentGadgetWheelConsumable: QuickSlotCommand;

  private let m_currentGadgetWheelGadget: QuickSlotCommand;

  private let m_currentVehicleWheelItem: QuickSlotCommand;

  private let m_currentGadgetWheelItem: QuickSlotCommand;

  private let m_currentInteractionWheelItem: QuickSlotCommand;

  private let m_OnVehPlayerStateDataChangedCallback: ref<CallbackHandle>;

  public final func OnGameAttach() -> Void {
    this.m_Player = this.GetOwner() as PlayerPuppet;
    this.m_QuickSlotsBB = GameInstance.GetBlackboardSystem(this.m_Player.GetGame()).Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    let vehBlackbord: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.m_Player.GetGame()).Get(GetAllBlackboardDefs().UI_ActiveVehicleData);
    this.m_OnVehPlayerStateDataChangedCallback = vehBlackbord.RegisterListenerVariant(GetAllBlackboardDefs().UI_ActiveVehicleData.VehPlayerStateData, this, n"OnVehPlayerStateDataChanged");
    this.InitializeCommandsData();
  }

  private final func OnVehPlayerStateDataChanged(vehPlayerStateData: Variant) -> Void {
    let vehData: VehEntityPlayerStateData = FromVariant(vehPlayerStateData);
    this.m_PlayerVehicleID = vehData.entID;
    this.m_IsPlayerInCar = vehData.state > 0;
  }

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }

  protected cb func OnQuickSlotButtonTap(evt: ref<QuickSlotButtonTap>) -> Bool {
    let currentCommand: QuickSlotCommand;
    let success: Bool;
    let index: Int32 = this.GetDPadIndex(evt.dPadItemDirection);
    if !this.m_IsPlayerInCar {
      if this.IsDPadActionAvaliable(index) {
        currentCommand = this.GetDPadCommandAtSlot(index);
        success = this.TryExecuteCommand(currentCommand);
        this.m_QuickSlotsBB.SetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.DPadCommand, ToVariant(new QuickSlotUIStructure(index, success)), true);
      };
    } else {
      if this.IsDPadActionAvaliable(index) {
        currentCommand = this.GetDPadCommandAtSlot(index);
        success = this.TryExecuteCommand(currentCommand);
        this.m_QuickSlotsBB.SetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.DPadCommand, ToVariant(new QuickSlotUIStructure(index, success)), true);
      };
    };
  }

  protected cb func OnCallAction(evt: ref<CallAction>) -> Bool {
    let command: QuickSlotCommand = this.CreateEmptyQuickSlotCommand();
    command.ActionType = evt.calledAction;
    this.ExecuteCommand(command);
  }

  protected cb func OnQuickSlotKeyboardTap(evt: ref<QuickSlotKeyboardTap>) -> Bool {
    let currentCommand: QuickSlotCommand;
    let success: Bool;
    let index: Int32 = evt.keyIndex;
    if this.IsKeyboardActionAvaliable(index) {
      currentCommand = this.GetKeyboardCommandAtSlot(index);
      success = this.TryExecuteCommand(currentCommand);
      this.m_QuickSlotsBB.SetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.KeyboardCommand, ToVariant(new QuickSlotUIStructure(index, success)), true);
    };
  }

  protected cb func OnQuickSlotButtonHoldStartEvent(evt: ref<QuickSlotButtonHoldStartEvent>) -> Bool {
    let wheelCommands: array<QuickSlotCommand>;
    if NotEquals(evt.dPadItemDirection, EDPadSlot.CallVehicle) {
      return false;
    };
    if !this.m_IsPlayerInCar {
      wheelCommands = this.GetWheelCommands(evt.dPadItemDirection);
    } else {
      wheelCommands = this.GetVehicleWheelCommands(evt.dPadItemDirection);
    };
    TimeDilationHelper.SetTimeDilationWithProfile(this.m_Player, "radialMenu", true);
    this.m_QuickSlotsBB.SetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.WheelInteractionStarted, ToVariant(new QuickWheelStartUIStructure(wheelCommands, evt.dPadItemDirection)), true);
  }

  public final func SetWheelItem(currentWheelItem: QuickSlotCommand) -> Void {
    switch currentWheelItem.itemType {
      case QuickSlotItemType.Vehicle:
        this.m_currentVehicleWheelItem = currentWheelItem;
        break;
      case QuickSlotItemType.Gadget:
        this.m_currentGadgetWheelGadget = currentWheelItem;
        this.m_currentGadgetWheelItem = currentWheelItem;
        break;
      case QuickSlotItemType.Cyberware:
        this.m_currentGadgetWheelGadget = currentWheelItem;
        this.m_currentGadgetWheelItem = currentWheelItem;
        break;
      case QuickSlotItemType.Consumable:
        this.m_currentGadgetWheelConsumable = currentWheelItem;
        this.m_currentGadgetWheelItem = currentWheelItem;
        break;
      case QuickSlotItemType.Weapon:
        this.m_currentWeaponWheelItem = currentWheelItem;
        break;
      case QuickSlotItemType.Interaction:
        this.m_currentInteractionWheelItem = currentWheelItem;
        break;
      default:
        this.m_currentWheelItem = currentWheelItem;
    };
  }

  public final func GetWheelItem(currentWheelItem: QuickSlotCommand) -> QuickSlotCommand {
    switch currentWheelItem.itemType {
      case QuickSlotItemType.Vehicle:
        return this.m_currentVehicleWheelItem;
      case QuickSlotItemType.Gadget:
        return this.m_currentGadgetWheelGadget;
      case QuickSlotItemType.Cyberware:
        return this.m_currentGadgetWheelGadget;
      case QuickSlotItemType.Consumable:
        return this.m_currentGadgetWheelConsumable;
      case QuickSlotItemType.Weapon:
        return this.m_currentWeaponWheelItem;
      case QuickSlotItemType.Interaction:
        return this.m_currentInteractionWheelItem;
      default:
        return this.m_currentWheelItem;
    };
  }

  public final const func GetQuickSlotCommandByDpadSlot(wheelType: EDPadSlot) -> QuickSlotCommand {
    switch wheelType {
      case EDPadSlot.VehicleWheel:
        return this.m_currentVehicleWheelItem;
      case EDPadSlot.GadgetWheel:
        return this.m_currentGadgetWheelItem;
      case EDPadSlot.ConsumableWheel:
        return this.m_currentGadgetWheelConsumable;
      case EDPadSlot.WeaponsWheel:
        return this.m_currentWeaponWheelItem;
      case EDPadSlot.InteractionWheel:
        return this.m_currentInteractionWheelItem;
      default:
        return this.m_currentWheelItem;
    };
  }

  protected final const func IsSelectingCombatItemPrevented() -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_Player, n"VehicleScene") || StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_Player, n"NoCombat") || StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_Player, n"FirearmsNoUnequip") || StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_Player, n"NoCombat") || StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_Player, n"FirearmsNoSwitch");
  }

  protected final const func IsSelectingCombatGadgetPrevented() -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_Player, n"Fists") || StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_Player, n"Melee") || StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_Player, n"Firearms");
  }

  protected final func GetDPadIndex(direction: EDPadSlot) -> Int32 {
    switch direction {
      case EDPadSlot.Left:
        return 0;
      case EDPadSlot.LeftDouble:
        return 4;
      case EDPadSlot.Up:
        return 1;
      case EDPadSlot.UpDouble:
        return 5;
      case EDPadSlot.Right:
        return 2;
      case EDPadSlot.RightDouble:
        return 6;
      case EDPadSlot.Down:
        return 3;
      case EDPadSlot.DownDouble:
        return 7;
      case EDPadSlot.WeaponsWheel:
        return 8;
    };
  }

  protected final func TryExecuteCommand(currentCommand: QuickSlotCommand) -> Bool {
    if IsDefined(this.m_Player) && NotEquals(currentCommand.ActionType, QuickSlotActionType.Undefined) {
      this.ExecuteCommand(currentCommand);
      return true;
    };
    return false;
  }

  public final func IsDPadActionAvaliable(direction: EDPadSlot) -> Bool {
    return this.IsDPadActionAvaliable(this.GetDPadIndex(direction));
  }

  public final func IsDPadActionAvaliable(actionIndex: Int32) -> Bool {
    let list: array<QuickSlotCommand> = this.m_IsPlayerInCar ? this.m_QuickDpadCommands_Vehicle : this.m_QuickDpadCommands;
    return actionIndex >= 0 && ArraySize(list) > actionIndex && list[actionIndex].IsSlotUnlocked;
  }

  public final func GetDPadCommandAtSlot(argIndex: Int32) -> QuickSlotCommand {
    let list: array<QuickSlotCommand> = this.m_IsPlayerInCar ? this.m_QuickDpadCommands_Vehicle : this.m_QuickDpadCommands;
    return list[argIndex];
  }

  public final static func GetMaxKeyboardItems() -> Int32 {
    return 8;
  }

  public final const func GetNumberOfItemsPerWheel() -> Int32 {
    return this.m_NumberOfItemsPerWheel;
  }

  public final func IsKeyboardActionAvaliable(actionIndex: Int32) -> Bool {
    let list: array<QuickSlotCommand> = this.m_IsPlayerInCar ? this.m_QuickKeyboardCommands_Vehicle : this.m_QuickKeyboardCommands;
    return actionIndex >= 0 && ArraySize(list) > actionIndex && list[actionIndex].IsSlotUnlocked;
  }

  public final func GetKeyboardCommandAtSlot(argIndex: Int32) -> QuickSlotCommand {
    let list: array<QuickSlotCommand> = this.m_IsPlayerInCar ? this.m_QuickKeyboardCommands_Vehicle : this.m_QuickKeyboardCommands;
    return list[argIndex];
  }

  private final const func CreateQuickSlotCommand(actionType: QuickSlotActionType, imageAtlasPath: CName, actionName: CName, maxTier: Int32, vehicleState: Int32, isLocked: Bool, isSlotUnlocked: Bool, opt intData: Int32, opt argTitle: String, opt argType: String) -> QuickSlotCommand {
    let newItem: QuickSlotCommand;
    newItem.IsSlotUnlocked = isSlotUnlocked;
    newItem.ActionType = actionType;
    newItem.IconName = imageAtlasPath;
    newItem.MaxTier = maxTier;
    newItem.VehicleState = vehicleState;
    newItem.IsLocked = isLocked;
    newItem.intData = intData;
    newItem.Title = argTitle;
    newItem.Type = argType;
    if NotEquals(actionName, n"") {
      newItem.ItemId = ItemID.FromTDBID(TDBID.Create(NameToString(actionName)));
    };
    return newItem;
  }

  private final const func CreateQuickSlotItemCommand(itemID: ItemID, argActionType: QuickSlotActionType, argIcon: CName, argTitle: String, argType: String, argDesc: String) -> QuickSlotCommand {
    let currWheelItem: QuickSlotCommand;
    currWheelItem.IconName = argIcon;
    currWheelItem.Title = argTitle;
    currWheelItem.Type = argType;
    currWheelItem.Description = argDesc;
    currWheelItem.ActionType = argActionType;
    currWheelItem.IsLocked = false;
    if itemID != ItemID.undefined() {
      currWheelItem.ItemId = itemID;
    };
    return currWheelItem;
  }

  private final const func GetActionData() -> QuickSlotCommand {
    let ret: QuickSlotCommand;
    return ret;
  }

  private final func InitializeCommandsData() -> Void {
    ArrayClear(this.m_QuickDpadCommands);
    ArrayPush(this.m_QuickDpadCommands, this.CreateQuickSlotCommand(QuickSlotActionType.Undefined, n"", n"", 1, 0, false, true));
    ArrayPush(this.m_QuickDpadCommands, this.CreateQuickSlotCommand(QuickSlotActionType.Undefined, n"", n"", 1, 0, false, true));
    ArrayPush(this.m_QuickDpadCommands, this.CreateQuickSlotCommand(QuickSlotActionType.CycleTrackedQuest, n"", n"", 1, 0, true, true, "Cycle Objective"));
    ArrayClear(this.m_QuickDpadCommands_Vehicle);
    ArrayPush(this.m_QuickDpadCommands_Vehicle, this.CreateQuickSlotCommand(QuickSlotActionType.OpenPhone, n"temp_kiroshi", n"", 1, 0, true, true));
    ArrayPush(this.m_QuickDpadCommands_Vehicle, this.CreateQuickSlotCommand(QuickSlotActionType.ToggleRadio, n"temp_car", n"", 1, 0, true, true));
    ArrayPush(this.m_QuickDpadCommands_Vehicle, this.CreateQuickSlotCommand(QuickSlotActionType.CycleTrackedQuest, n"temp_katana", n"", 1, 0, true, true, "Cycle Objective"));
    ArrayClear(this.m_QuickKeyboardCommands);
    ArrayPush(this.m_QuickKeyboardCommands, this.CreateQuickSlotCommand(QuickSlotActionType.OpenPhone, n"temp_kiroshi", n"", 1, 0, false, true));
    ArrayClear(this.m_QuickKeyboardCommands_Vehicle);
    ArrayPush(this.m_QuickKeyboardCommands_Vehicle, this.CreateQuickSlotCommand(QuickSlotActionType.OpenPhone, n"temp_kiroshi", n"", 1, 0, false, true));
    ArrayPush(this.m_DefaultHoldCommands, this.CreateQuickSlotCommand(QuickSlotActionType.Undefined, n"", n"", 1, 0, false, false));
    ArrayPush(this.m_DefaultHoldCommands, this.CreateQuickSlotCommand(QuickSlotActionType.Undefined, n"", n"", 1, 0, false, false));
    ArrayPush(this.m_DefaultHoldCommands, this.CreateQuickSlotCommand(QuickSlotActionType.Undefined, n"", n"", 1, 0, false, false));
    ArrayPush(this.m_DefaultHoldCommands, this.CreateQuickSlotCommand(QuickSlotActionType.Undefined, n"", n"", 1, 0, false, false));
    ArrayPush(this.m_DefaultHoldCommands_Vehicle, this.CreateQuickSlotCommand(QuickSlotActionType.Undefined, n"", n"", 1, 0, false, false));
    ArrayPush(this.m_DefaultHoldCommands_Vehicle, this.CreateQuickSlotCommand(QuickSlotActionType.Undefined, n"", n"", 1, 0, false, false));
    ArrayPush(this.m_DefaultHoldCommands_Vehicle, this.CreateQuickSlotCommand(QuickSlotActionType.TurnOffRadio, n"temp_car", n"", 1, 0, true, true, "TURN OFF", "RADIO"));
    ArrayPush(this.m_DefaultHoldCommands_Vehicle, this.CreateQuickSlotCommand(QuickSlotActionType.Undefined, n"", n"", 1, 0, false, false));
  }

  public final func GetWheelCommands(direction: EDPadSlot) -> array<QuickSlotCommand> {
    let currentWheelCommands: array<QuickSlotCommand>;
    switch direction {
      case EDPadSlot.VehicleWheel:
        if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_Player, n"VehicleNoInteraction") {
          this.GetEmptyWheel(currentWheelCommands);
          return currentWheelCommands;
        };
        this.GetVehicleWheel(currentWheelCommands);
        return currentWheelCommands;
      case EDPadSlot.GadgetWheel:
        if this.IsSelectingCombatItemPrevented() || this.IsSelectingCombatGadgetPrevented() {
          this.GetEmptyWheel(currentWheelCommands);
          return currentWheelCommands;
        };
        this.GetRPGWheel(currentWheelCommands);
        return currentWheelCommands;
      case EDPadSlot.WeaponsWheel:
        if this.IsSelectingCombatItemPrevented() {
          this.GetEmptyWheel(currentWheelCommands);
          return currentWheelCommands;
        };
        this.ChooseWeaponsWheel(currentWheelCommands);
        return currentWheelCommands;
      case EDPadSlot.ConsumableWheel:
        this.GetConsumablesWheel(currentWheelCommands);
        return currentWheelCommands;
    };
  }

  public final func GetVehicleWheelCommands(direction: EDPadSlot) -> array<QuickSlotCommand> {
    let currentWheelCommands: array<QuickSlotCommand>;
    switch direction {
      case EDPadSlot.VehicleInsideWheel:
        this.GetVehicleInsideWheel(currentWheelCommands);
        return currentWheelCommands;
      case EDPadSlot.GadgetWheel:
        if this.IsSelectingCombatItemPrevented() {
          this.GetEmptyWheel(currentWheelCommands);
          return currentWheelCommands;
        };
        this.GetRPGWheel(currentWheelCommands);
        return currentWheelCommands;
      case EDPadSlot.WeaponsWheel:
        this.ChooseWeaponsWheel(currentWheelCommands);
        return currentWheelCommands;
      case EDPadSlot.ConsumableWheel:
        this.GetConsumablesWheel(currentWheelCommands);
        return currentWheelCommands;
    };
  }

  private final const func GetVehicleObject() -> ref<VehicleObject> {
    let mountInfo: MountingInfo = GameInstance.GetMountingFacility(this.m_Player.GetGame()).GetMountingInfoSingleWithIds(this.m_Player.GetEntityID());
    let entity: ref<Entity> = GameInstance.FindEntityByID(this.m_Player.GetGame(), mountInfo.parentId);
    let vehicleEntity: ref<VehicleObject> = entity as VehicleObject;
    return vehicleEntity;
  }

  public final const func GetVehicleInsideWheel(out wheel: array<QuickSlotCommand>) -> Void {
    let isRadioActive: Bool = this.GetVehicleObject().GetBlackboard().GetBool(GetAllBlackboardDefs().Vehicle.VehRadioState);
    ArrayPush(wheel, this.CreateQuickSlotCommand(QuickSlotActionType.ToggleRadio, n"temp_car", n"", 1, 0, true, true, "NEXT STATION", "RADIO"));
    if isRadioActive {
      ArrayPush(wheel, this.CreateQuickSlotCommand(QuickSlotActionType.TurnOffRadio, n"temp_car", n"", 1, 0, true, true, "TURN OFF", "RADIO"));
    };
  }

  public final const func GetRPGWheel(out rpgWheel: array<QuickSlotCommand>) -> Void {
    this.GetQuickWheel(rpgWheel);
  }

  public final const func GetConsumablesWheel(out wheel: array<QuickSlotCommand>) -> Void {
    this.PushBackCommands(gamedataEquipmentArea.Consumable, wheel);
  }

  public final const func GetCyberwareWheel(out wheel: array<QuickSlotCommand>) -> Void {
    this.GetLauncher(wheel);
    this.PushBackCommands(gamedataEquipmentArea.CyberwareWheel, wheel);
  }

  public final const func GetGadgetsWheel(out wheel: array<QuickSlotCommand>) -> Void {
    this.PushBackCommands(gamedataEquipmentArea.QuickSlot, wheel);
  }

  public final const func GetQuickWheel(out wheel: array<QuickSlotCommand>) -> Void {
    this.PushBackCommands(gamedataEquipmentArea.QuickWheel, wheel);
  }

  public final const func GetLauncher(out wheel: array<QuickSlotCommand>) -> Void {
    let record: ref<Item_Record>;
    let item: ItemID = EquipmentSystem.GetData(this.m_Player).GetActiveItem(gamedataEquipmentArea.ArmsCW);
    if ItemID.IsValid(item) {
      record = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item));
      if Equals(record.ItemType().Type(), gamedataItemType.Cyb_Launcher) {
        this.PushBackCommands(gamedataEquipmentArea.ArmsCW, wheel);
      };
    };
  }

  public final const func ChooseWeaponsWheel(out weaponsWheel: array<QuickSlotCommand>) -> Void {
    if this.IsSelectingCombatItemPrevented() {
      this.GetEmptyWheel(weaponsWheel);
    } else {
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_Player, n"Fists") {
        this.GetFistFightOnlyWeaponsWheel(weaponsWheel);
      } else {
        if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_Player, n"Melee") {
          this.GetMeleeOnlyWeaponsWheel(weaponsWheel);
        } else {
          if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_Player, n"OneHandedFirearms") {
            this.GetOneHandedOnlyOnlyWeaponsWheel(weaponsWheel);
          } else {
            if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_Player, n"Firearms") {
              this.GetFirearmsOnlyWeaponsWheel(weaponsWheel);
            } else {
              this.GetRegularWeaponsWheel(weaponsWheel);
            };
          };
        };
      };
    };
  }

  public final const func GetRegularWeaponsWheel(out weaponsWheel: array<QuickSlotCommand>) -> Void {
    let allowedItemTypes: array<gamedataItemType>;
    this.GetWeaponsWheel(weaponsWheel, allowedItemTypes);
  }

  public final const func GetEmptyWheel(out weaponsWheel: array<QuickSlotCommand>) -> Void {
    let allowedItemTypes: array<gamedataItemType>;
    ArrayPush(allowedItemTypes, gamedataItemType.Invalid);
    this.GetWeaponsWheel(weaponsWheel, allowedItemTypes);
  }

  public final const func GetFistFightOnlyWeaponsWheel(out weaponsWheel: array<QuickSlotCommand>) -> Void {
    let allowedItemTypes: array<gamedataItemType>;
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_Fists);
    ArrayPush(allowedItemTypes, gamedataItemType.Cyb_StrongArms);
    this.GetWeaponsWheel(weaponsWheel, allowedItemTypes);
  }

  public final const func GetMeleeOnlyWeaponsWheel(out weaponsWheel: array<QuickSlotCommand>) -> Void {
    let allowedItemTypes: array<gamedataItemType>;
    ArrayPush(allowedItemTypes, gamedataItemType.Cyb_MantisBlades);
    ArrayPush(allowedItemTypes, gamedataItemType.Cyb_NanoWires);
    ArrayPush(allowedItemTypes, gamedataItemType.Cyb_StrongArms);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_Fists);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_Hammer);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_Katana);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_Knife);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_LongBlade);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_Melee);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_OneHandedClub);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_ShortBlade);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_TwoHandedClub);
    this.GetWeaponsWheel(weaponsWheel, allowedItemTypes, WeaponObject.GetMeleeWeaponTag());
  }

  public final const func GetOneHandedOnlyOnlyWeaponsWheel(out weaponsWheel: array<QuickSlotCommand>) -> Void {
    let allowedItemTypes: array<gamedataItemType>;
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_Handgun);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_Revolver);
    this.GetWeaponsWheel(weaponsWheel, allowedItemTypes, WeaponObject.GetOneHandedRangedWeaponTag());
  }

  public final const func GetFirearmsOnlyWeaponsWheel(out weaponsWheel: array<QuickSlotCommand>) -> Void {
    let allowedItemTypes: array<gamedataItemType>;
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_AssaultRifle);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_Handgun);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_HeavyMachineGun);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_LightMachineGun);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_PrecisionRifle);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_Revolver);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_Rifle);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_Shotgun);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_ShotgunDual);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_SniperRifle);
    ArrayPush(allowedItemTypes, gamedataItemType.Wea_SubmachineGun);
    this.GetWeaponsWheel(weaponsWheel, allowedItemTypes, WeaponObject.GetRangedWeaponTag());
  }

  private final const func GetWeaponsWheel(out weaponsWheel: array<QuickSlotCommand>, const opt allowedItemTypes: array<gamedataItemType>, const opt allowedTag: CName) -> Void {
    let holsterCommand: QuickSlotCommand = this.CreateQuickSlotCommand(QuickSlotActionType.HideWeapon, n"temp_switchweapon", n"HOLSTER WEAPON", 1, 0, false, false);
    holsterCommand.itemType = QuickSlotItemType.Weapon;
    let equipFistsCommand: QuickSlotCommand = this.CreateQuickSlotCommand(QuickSlotActionType.EquipFists, n"fist", n"FISTS", 1, 0, false, false);
    equipFistsCommand.itemType = QuickSlotItemType.Weapon;
    ArrayPush(weaponsWheel, holsterCommand);
    this.PushBackCommands(gamedataEquipmentArea.WeaponWheel, weaponsWheel, allowedItemTypes, allowedTag);
    if (ArraySize(allowedItemTypes) == 0 || ArrayContains(allowedItemTypes, gamedataItemType.Wea_Fists)) && !ItemID.IsValid(EquipmentSystem.GetData(this.m_Player).GetActiveMeleeWare()) {
      ArrayPush(weaponsWheel, equipFistsCommand);
    };
  }

  public final const func GetVehicleWheel(out vehicleWheel: array<QuickSlotCommand>) -> Void {
    let gmplSettingBB: ref<IBlackboard>;
    let i: Int32;
    let iconPath: CName;
    let itemRecord: ref<Vehicle_Record>;
    let quickSlotCommand: QuickSlotCommand;
    let summonToggleEnabled: Bool;
    let title: String;
    let type: String;
    let vehicles: array<PlayerVehicle>;
    GameInstance.GetVehicleSystem(this.m_Player.GetGame()).GetPlayerUnlockedVehicles(vehicles);
    i = 0;
    while i < ArraySize(vehicles) {
      if TDBID.IsValid(vehicles[i].recordID) {
        itemRecord = TweakDBInterface.GetVehicleRecord(vehicles[i].recordID);
        iconPath = this.FindTempVehicleIcon(vehicles[i]);
        title = itemRecord.Model().EnumName();
        type = itemRecord.Type().EnumName();
        quickSlotCommand = this.CreateQuickSlotItemCommand(ItemID.undefined(), QuickSlotActionType.SetActiveVehicle, iconPath, title, type, "");
        quickSlotCommand.playerVehicleData = vehicles[i];
        quickSlotCommand.itemType = QuickSlotItemType.Vehicle;
        ArrayPush(vehicleWheel, quickSlotCommand);
      };
      i += 1;
    };
    gmplSettingBB = GameInstance.GetBlackboardSystem(this.m_Player.GetGame()).Get(GetAllBlackboardDefs().GameplaySettings);
    summonToggleEnabled = gmplSettingBB.GetBool(GetAllBlackboardDefs().GameplaySettings.EnableVehicleToggleSummonMode);
    if summonToggleEnabled {
      title = "Toggle summon mode";
      quickSlotCommand = this.CreateQuickSlotItemCommand(ItemID.undefined(), QuickSlotActionType.ToggleSummonMode, n"", title, "", "");
      quickSlotCommand.itemType = QuickSlotItemType.Vehicle;
      ArrayPush(vehicleWheel, quickSlotCommand);
    };
  }

  private final const func FindTempVehicleIcon(vehicle: PlayerVehicle) -> CName {
    switch vehicle.vehicleType {
      case gamedataVehicleType.Car:
        return n"temp_car";
      case gamedataVehicleType.Bike:
        return n"temp_bike";
      default:
        return n"";
    };
  }

  protected final const func PushBackCommands(area: gamedataEquipmentArea, out commandList: array<QuickSlotCommand>, const opt allowedItemTypes: array<gamedataItemType>, const opt allowedTag: CName) -> Void {
    let areaCommandList: array<QuickSlotCommand> = this.GetEquipAreaCommands(area, allowedItemTypes, allowedTag);
    let i: Int32 = 0;
    while i < ArraySize(areaCommandList) {
      ArrayPush(commandList, areaCommandList[i]);
      i += 1;
    };
  }

  public final const func GetEquipAreaCommands(const equipArea: gamedataEquipmentArea, const opt allowedItemTypes: array<gamedataItemType>, const opt allowedTag: CName) -> array<QuickSlotCommand> {
    let ammoCount: String;
    let iconPath: CName;
    let itemID: ItemID;
    let itemRecord: ref<Item_Record>;
    let itemTags: array<CName>;
    let quickSlotCommand: QuickSlotCommand;
    let quickSlotCommands: array<QuickSlotCommand>;
    let title: String;
    let type: String;
    let equipData: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(this.m_Player);
    let numSlots: Int32 = equipData.GetNumberOfSlots(equipArea);
    let i: Int32 = 0;
    while i < numSlots {
      itemID = equipData.GetItemInEquipSlot(equipArea, i);
      quickSlotCommand.equipType = equipArea;
      quickSlotCommand.slotIndex = i;
      if itemID == ItemID.undefined() {
        quickSlotCommand = QuickSlotsManager.CreateBlankWheelCommand();
        ArrayPush(quickSlotCommands, quickSlotCommand);
      } else {
        itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
        if ArraySize(allowedItemTypes) > 0 && !ArrayContains(allowedItemTypes, itemRecord.ItemType().Type()) {
          quickSlotCommand = QuickSlotsManager.CreateBlankWheelCommand();
          ArrayPush(quickSlotCommands, quickSlotCommand);
        } else {
          if IsNameValid(allowedTag) {
            itemTags = itemRecord.Tags();
            if !ArrayContains(itemTags, allowedTag) {
              quickSlotCommand = QuickSlotsManager.CreateBlankWheelCommand();
              ArrayPush(quickSlotCommands, quickSlotCommand);
            } else {
              iconPath = StringToName(itemRecord.IconPath());
              title = NameToString(itemRecord.DisplayName());
              type = LocKeyToString(itemRecord.ItemType().LocalizedType());
              ammoCount = RPGManager.GetAmmoCount(this.m_Player, itemID);
              quickSlotCommand = this.CreateQuickSlotItemCommand(itemID, QuickSlotActionType.SelectItem, iconPath, title, type, ammoCount);
              quickSlotCommand.itemType = this.GetQuickSlotItemTypeByEquipArea(equipArea);
              ArrayPush(quickSlotCommands, quickSlotCommand);
            };
          };
          iconPath = StringToName(itemRecord.IconPath());
          title = NameToString(itemRecord.DisplayName());
          type = LocKeyToString(itemRecord.ItemType().LocalizedType());
          ammoCount = RPGManager.GetAmmoCount(this.m_Player, itemID);
          quickSlotCommand = this.CreateQuickSlotItemCommand(itemID, QuickSlotActionType.SelectItem, iconPath, title, type, ammoCount);
          quickSlotCommand.itemType = this.GetQuickSlotItemTypeByEquipArea(equipArea);
          ArrayPush(quickSlotCommands, quickSlotCommand);
        };
      };
      i += 1;
    };
    return quickSlotCommands;
  }

  protected final const func GetQuickSlotItemTypeByEquipArea(eqArea: gamedataEquipmentArea) -> QuickSlotItemType {
    switch eqArea {
      case gamedataEquipmentArea.Consumable:
        return QuickSlotItemType.Consumable;
      case gamedataEquipmentArea.QuickSlot:
        return QuickSlotItemType.Gadget;
      case gamedataEquipmentArea.QuickWheel:
        return QuickSlotItemType.Gadget;
      case gamedataEquipmentArea.WeaponWheel:
        return QuickSlotItemType.Weapon;
      case gamedataEquipmentArea.CyberwareWheel:
        return QuickSlotItemType.Cyberware;
      case gamedataEquipmentArea.ArmsCW:
        return QuickSlotItemType.Cyberware;
      default:
        return QuickSlotItemType.Undefined;
    };
  }

  private final func ChooseWheelItem(direction: EDPadSlot, wheelItem: QuickSlotCommand) -> Bool {
    let success: Bool = this.TryExecuteCommand(wheelItem);
    return success;
  }

  public final static func CreateBlankWheelCommand() -> QuickSlotCommand {
    let wheelCommand: QuickSlotCommand;
    wheelCommand.ActionType = QuickSlotActionType.Undefined;
    wheelCommand.IconName = n"temp_x";
    wheelCommand.Type = "";
    wheelCommand.Title = "";
    wheelCommand.Description = "";
    return wheelCommand;
  }

  protected final func ExecuteCommand(command: QuickSlotCommand) -> Void {
    switch command.ActionType {
      case QuickSlotActionType.SelectItem:
        this.SelectItem(command);
        break;
      case QuickSlotActionType.HideWeapon:
        this.HideWeapon();
        break;
      case QuickSlotActionType.EquipFists:
        this.RequestEquipFists();
        break;
      case QuickSlotActionType.OpenPhone:
        this.UsePhone();
        break;
      case QuickSlotActionType.ToggleRadio:
        this.SendRadioEvent(true, false, 0);
        break;
      case QuickSlotActionType.SelectRadioStation:
        this.SendRadioEvent(true, true, command.intData);
        break;
      case QuickSlotActionType.TurnOffRadio:
        this.SendRadioEvent(false, false, 0);
        break;
      case QuickSlotActionType.SetActiveVehicle:
        this.SetActiveVehicle(command.playerVehicleData);
        break;
      case QuickSlotActionType.SummonVehicle:
        this.SummonVehicle();
        break;
      case QuickSlotActionType.QuickHack:
        this.ApplyQuickHack(command);
        break;
      case QuickSlotActionType.ToggleSummonMode:
        this.ToggleSummonMode();
    };
  }

  public final func SelectItem(command: QuickSlotCommand) -> Void {
    if Equals(command.itemType, QuickSlotItemType.Weapon) {
      this.RequestWeaponEquip(command.ItemId);
    } else {
      this.AssignItem(command.ItemId);
    };
  }

  private final func ToggleFireMode() -> Void {
    this.m_Player.GetPlayerStateMachineBlackboard().SetBool(GetAllBlackboardDefs().PlayerStateMachine.ToggleFireMode, true);
  }

  private final func HideWeapon() -> Void {
    let equipmentManipulationRequest: ref<EquipmentSystemWeaponManipulationRequest> = new EquipmentSystemWeaponManipulationRequest();
    let eqSystem: wref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(this.m_Player.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    equipmentManipulationRequest.requestType = EquipmentManipulationAction.UnequipWeapon;
    equipmentManipulationRequest.owner = this.m_Player;
    eqSystem.QueueRequest(equipmentManipulationRequest);
  }

  private final func UsePhone() -> Void {
    GameInstance.GetScriptableSystemsContainer(this.m_Player.GetGame()).Get(n"PhoneSystem").QueueRequest(new UsePhoneRequest());
  }

  public final func SetActiveVehicle(vehicleData: PlayerVehicle) -> Void {
    if TDBID.IsValid(vehicleData.recordID) {
      GameInstance.GetVehicleSystem(this.m_Player.GetGame()).TogglePlayerActiveVehicle(Cast(vehicleData.recordID), vehicleData.vehicleType, true);
      (this.GetPS() as QuickSlotsManagerPS).SetActiveType(vehicleData.vehicleType);
    };
  }

  public final func SummonVehicle() -> Void {
    let dpadAction: ref<DPADActionPerformed> = new DPADActionPerformed();
    dpadAction.action = EHotkey.DPAD_RIGHT;
    dpadAction.state = EUIActionState.COMPLETED;
    dpadAction.successful = true;
    GameInstance.GetVehicleSystem(this.m_Player.GetGame()).SpawnPlayerVehicle((this.GetPS() as QuickSlotsManagerPS).GetActiveType());
    GameInstance.GetUISystem(this.m_Player.GetGame()).QueueEvent(dpadAction);
  }

  private final func ApplyQuickHack(command: QuickSlotCommand) -> Void {
    let commandUsed: ref<QuickSlotCommandUsed> = new QuickSlotCommandUsed();
    commandUsed.action = command.interactiveAction;
    this.m_Player.QueueEventForEntityID(command.interactiveActionOwner, commandUsed);
  }

  private final func ToggleSummonMode() -> Void {
    GameInstance.GetVehicleSystem(this.m_Player.GetGame()).ToggleSummonMode();
  }

  public final func SendRadioEvent(toggle: Bool, setStation: Bool, stationNumer: Int32) -> Void {
    let vehRadioEvent: ref<VehicleRadioEvent> = new VehicleRadioEvent();
    vehRadioEvent.toggle = toggle;
    vehRadioEvent.setStation = setStation;
    vehRadioEvent.station = stationNumer;
    this.m_Player.QueueEventForEntityID(this.m_PlayerVehicleID, vehRadioEvent);
  }

  public final func RequestWeaponEquip(itemId: ItemID) -> Void {
    let setActiveItemRequest: ref<SetActiveItemInEquipmentArea> = new SetActiveItemInEquipmentArea();
    let equipmentManipulationRequest: ref<EquipmentSystemWeaponManipulationRequest> = new EquipmentSystemWeaponManipulationRequest();
    let eqSystem: wref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(this.m_Player.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    setActiveItemRequest.itemID = itemId;
    setActiveItemRequest.owner = this.m_Player;
    eqSystem.QueueRequest(setActiveItemRequest);
    equipmentManipulationRequest.requestType = EquipmentManipulationAction.RequestActiveWeapon;
    equipmentManipulationRequest.owner = this.m_Player;
    eqSystem.QueueRequest(equipmentManipulationRequest);
  }

  public final func RequestEquipFists() -> Void {
    let equipmentManipulationRequest: ref<EquipmentSystemWeaponManipulationRequest> = new EquipmentSystemWeaponManipulationRequest();
    let eqSystem: wref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(this.m_Player.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    equipmentManipulationRequest.requestType = EquipmentManipulationAction.RequestFists;
    equipmentManipulationRequest.owner = this.m_Player;
    eqSystem.QueueRequest(equipmentManipulationRequest);
  }

  public final func AssignItem(itemId: ItemID) -> Void {
    let setActiveItemRequest: ref<SetActiveItemInEquipmentArea> = new SetActiveItemInEquipmentArea();
    let eqSystem: wref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(this.m_Player.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    setActiveItemRequest.itemID = itemId;
    setActiveItemRequest.owner = this.m_Player;
    eqSystem.QueueRequest(setActiveItemRequest);
  }

  public final func AssignItemToCyberwareSlot(itemId: ItemID, slotIndex: Int32) -> Void {
    let eqSystem: wref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(this.m_Player.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    let request: ref<AssignToCyberwareWheelRequest> = new AssignToCyberwareWheelRequest();
    request.owner = this.m_Player;
    request.itemID = itemId;
    request.slotIndex = slotIndex;
    eqSystem.QueueRequest(request);
  }

  private final func IsPhoneAvailable() -> Bool {
    let context: JournalRequestContext;
    let entries: array<wref<JournalEntry>>;
    context.stateFilter.active = true;
    let journalMgr: ref<JournalManager> = GameInstance.GetJournalManager(this.m_Player.GetGame());
    journalMgr.GetContacts(context, entries);
    return ArraySize(entries) > 0 && (GameInstance.GetScriptableSystemsContainer(this.m_Player.GetGame()).Get(n"PhoneSystem") as PhoneSystem).IsPhoneAvailable();
  }

  public final func GetAssignedQuickSlotCommand(itemType: QuickSlotItemType) -> QuickSlotCommand {
    let i: Int32;
    let quickSlots: array<QuickSlotCommand>;
    let item: ItemID = this.GetAssignedItemIDByType(itemType);
    if Equals(itemType, QuickSlotItemType.Vehicle) {
      LogWarning("GetAssignedQuickSlotCommand() does not work for QuickSlotItemType.Vehicle yet, we need to update VehicleUI data");
    };
    if !ItemID.IsValid(item) {
      return this.CreateEmptyQuickSlotCommand();
    };
    this.PushBackCommands(this.GetGamedataEquipmentAreaFromItemType(itemType), quickSlots);
    i = 0;
    while i < ArraySize(quickSlots) {
      if item == quickSlots[i].ItemId {
        return quickSlots[i];
      };
      i += 1;
    };
    return this.CreateEmptyQuickSlotCommand();
  }

  private final func GetAssignedItemIDByType(itemType: QuickSlotItemType) -> ItemID {
    switch itemType {
      case QuickSlotItemType.Weapon:
        return EquipmentSystem.GetData(this.m_Player).GetActiveItem(gamedataEquipmentArea.WeaponWheel);
      case QuickSlotItemType.Consumable:
        return EquipmentSystem.GetData(this.m_Player).GetActiveConsumable();
      case QuickSlotItemType.Gadget:
        return EquipmentSystem.GetData(this.m_Player).GetActiveGadget();
      default:
        return ItemID.undefined();
    };
  }

  private final func GetGamedataEquipmentAreaFromItemType(itemType: QuickSlotItemType) -> gamedataEquipmentArea {
    switch itemType {
      case QuickSlotItemType.Weapon:
        return gamedataEquipmentArea.WeaponWheel;
      case QuickSlotItemType.Consumable:
        return gamedataEquipmentArea.Consumable;
      case QuickSlotItemType.Gadget:
        return gamedataEquipmentArea.QuickWheel;
      default:
        return gamedataEquipmentArea.Invalid;
    };
  }

  protected final func CreateEmptyQuickSlotCommand() -> QuickSlotCommand {
    return this.CreateQuickSlotItemCommand(ItemID.undefined(), QuickSlotActionType.Undefined, n"", "", "", "");
  }
}
