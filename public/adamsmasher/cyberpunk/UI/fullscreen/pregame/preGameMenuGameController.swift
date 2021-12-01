
public native class gameuiPreGameMenuGameController extends gameuiBaseMenuGameController {

  protected cb func OnInitialize() -> Bool {
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnBackAction");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnBackAction");
  }

  protected cb func OnPuppetReady(sceneName: CName, puppet: ref<gamePuppet>) -> Bool {
    let item: ItemID;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(puppet.GetGame());
    let gender: CName = puppet.GetResolvedGenderName();
    if Equals(gender, n"Male") {
      item = ItemID.FromTDBID(t"Items.CharacterCustomizationMaHead");
    } else {
      if Equals(gender, n"Female") {
        item = ItemID.FromTDBID(t"Items.CharacterCustomizationWaHead");
      };
    };
    transactionSystem.GiveItem(puppet, item, 1);
    transactionSystem.AddItemToSlot(puppet, EquipmentSystem.GetPlacementSlot(item), item);
    item = ItemID.FromTDBID(t"Items.CharacterCustomizationArms");
    transactionSystem.GiveItem(puppet, item, 1);
    transactionSystem.AddItemToSlot(puppet, EquipmentSystem.GetPlacementSlot(item), item);
    this.UpdateCensorshipItems(puppet, transactionSystem, gender);
  }

  protected cb func OnCensorFlagsChanged(sceneName: CName, puppet: ref<gamePuppet>) -> Bool {
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(puppet.GetGame());
    let gender: CName = puppet.GetResolvedGenderName();
    this.UpdateCensorshipItems(puppet, transactionSystem, gender);
  }

  public final func UpdateCensorshipItems(puppet: ref<gamePuppet>, transactionSystem: ref<TransactionSystem>, gender: CName) -> Void {
    let characterCustomizationSystem: ref<gameuiICharacterCustomizationSystem>;
    let item1: ItemID = ItemID.FromTDBID(t"Items.Underwear_Basic_01_Bottom");
    let item2: ItemID = ItemID.FromTDBID(t"Items.Underwear_Basic_01_Top");
    transactionSystem.RemoveItemFromSlot(puppet, EquipmentSystem.GetPlacementSlot(item1));
    transactionSystem.RemoveItemByTDBID(puppet, ItemID.GetTDBID(item1), 1);
    if Equals(gender, n"Female") {
      transactionSystem.RemoveItemFromSlot(puppet, EquipmentSystem.GetPlacementSlot(item2));
      transactionSystem.RemoveItemByTDBID(puppet, ItemID.GetTDBID(item2), 1);
    };
    characterCustomizationSystem = GameInstance.GetCharacterCustomizationSystem(puppet.GetGame());
    if !characterCustomizationSystem.IsNudityAllowed() {
      transactionSystem.GiveItem(puppet, item1, 1);
      transactionSystem.AddItemToSlot(puppet, EquipmentSystem.GetPlacementSlot(item1), item1);
      if Equals(gender, n"Female") {
        transactionSystem.GiveItem(puppet, item2, 1);
        transactionSystem.AddItemToSlot(puppet, EquipmentSystem.GetPlacementSlot(item2), item2);
      };
    };
  }

  protected cb func OnBackAction(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"back") {
      this.SpawnMenuInstanceEvent(n"OnSettingsBack");
    };
  }
}
