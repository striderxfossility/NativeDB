
public class ItemInSlotPrereqState extends PrereqState {

  public let m_listener: ref<ItemInSlotCallback>;

  public let m_owner: wref<GameObject>;

  public final func SlotFilled(slotID: TweakDBID, itemID: ItemID) -> Void {
    let checkPassed: Bool;
    let prereq: ref<ItemInSlotPrereq> = this.GetPrereq() as ItemInSlotPrereq;
    if slotID == prereq.m_slotID {
      checkPassed = prereq.Evaluate(itemID, this.m_owner);
      this.OnChanged(checkPassed);
    };
  }

  public final func SlotEmptied(slotID: TweakDBID, itemID: ItemID) -> Void {
    let prereq: ref<ItemInSlotPrereq> = this.GetPrereq() as ItemInSlotPrereq;
    if slotID == prereq.m_slotID {
      this.OnChanged(false);
    };
  }
}

public class ItemInSlotPrereq extends IScriptablePrereq {

  public let m_slotID: TweakDBID;

  public let m_slotCheckType: EItemSlotCheckType;

  public let m_itemType: gamedataItemType;

  public let m_itemCategory: gamedataItemCategory;

  public let m_weaponEvolution: gamedataWeaponEvolution;

  public let m_itemTag: CName;

  public let m_invert: Bool;

  public let m_skipOnApply: Bool;

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    let castedState: ref<ItemInSlotPrereqState> = state as ItemInSlotPrereqState;
    castedState.m_listener = new ItemInSlotCallback();
    castedState.m_listener.slotID = this.m_slotID;
    castedState.m_owner = owner;
    castedState.m_listener.RegisterState(castedState);
    GameInstance.GetTransactionSystem(game).RegisterAttachmentSlotListener(owner, castedState.m_listener);
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<StatPrereqState> = state as StatPrereqState;
    if IsDefined(castedState) {
      castedState.m_listener = null;
    };
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let itemObj: wref<ItemObject>;
    let castedState: ref<ItemInSlotPrereqState> = state as ItemInSlotPrereqState;
    let owner: wref<GameObject> = context as GameObject;
    if this.m_skipOnApply {
      return;
    };
    itemObj = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemInSlot(owner, this.m_slotID);
    if IsDefined(itemObj) {
      castedState.SlotFilled(this.m_slotID, itemObj.GetItemID());
    };
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let itemObj: wref<ItemObject>;
    let owner: wref<GameObject> = context as GameObject;
    if this.m_skipOnApply {
      return false;
    };
    itemObj = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemInSlot(owner, this.m_slotID);
    if IsDefined(itemObj) {
      return this.Evaluate(itemObj.GetItemID(), owner);
    };
    return false;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".checkType", "");
    this.m_slotCheckType = IntEnum(Cast(EnumValueFromString("EItemSlotCheckType", str)));
    str = TweakDBInterface.GetString(recordID + t".attachmentSlot", "");
    this.m_slotID = TDBID.Create(str);
    str = TweakDBInterface.GetString(recordID + t".itemType", "");
    this.m_itemType = IntEnum(Cast(EnumValueFromString("gamedataItemType", str)));
    str = TweakDBInterface.GetString(recordID + t".itemCategory", "");
    this.m_itemCategory = IntEnum(Cast(EnumValueFromString("gamedataItemCategory", str)));
    str = TweakDBInterface.GetString(recordID + t".weaponEvolution", "");
    this.m_weaponEvolution = IntEnum(Cast(EnumValueFromString("gamedataWeaponEvolution", str)));
    str = TweakDBInterface.GetString(recordID + t".itemTag", "");
    this.m_itemTag = StringToName(str);
    this.m_invert = TweakDBInterface.GetBool(recordID + t".inverted", false);
    this.m_skipOnApply = TweakDBInterface.GetBool(recordID + t".skipOnApply", false);
  }

  public final const func Evaluate(itemID: ItemID, owner: wref<GameObject>) -> Bool {
    let result: Bool;
    switch this.m_slotCheckType {
      case EItemSlotCheckType.NONE:
        result = false;
        break;
      case EItemSlotCheckType.TAG:
        result = this.Evaluate(itemID, this.m_itemTag);
        break;
      case EItemSlotCheckType.TYPE:
        result = this.Evaluate(RPGManager.GetItemType(itemID));
        break;
      case EItemSlotCheckType.CATEGORY:
        result = this.Evaluate(RPGManager.GetItemCategory(itemID));
        break;
      case EItemSlotCheckType.EVOLUTION:
        result = this.Evaluate(RPGManager.GetWeaponEvolution(itemID));
        break;
      case EItemSlotCheckType.FULLY_MODDED:
        result = this.CheckGenericWeaponModSlots(itemID, owner);
        break;
      default:
        result = false;
    };
    return this.m_invert ? !result : result;
  }

  public final const func Evaluate(itemCategory: gamedataItemCategory) -> Bool {
    return Equals(itemCategory, this.m_itemCategory);
  }

  public final const func Evaluate(itemType: gamedataItemType) -> Bool {
    return Equals(itemType, this.m_itemType);
  }

  public final const func Evaluate(weaponEvolution: gamedataWeaponEvolution) -> Bool {
    return Equals(weaponEvolution, this.m_weaponEvolution);
  }

  public final const func Evaluate(itemID: ItemID, tag: CName) -> Bool {
    let tags: array<CName> = RPGManager.GetItemRecord(itemID).Tags();
    return ArrayContains(tags, tag);
  }

  public final const func CheckGenericWeaponModSlots(itemID: ItemID, owner: wref<GameObject>) -> Bool {
    let attachmentSlotList: array<TweakDBID>;
    let index: Int32;
    let quality: Float;
    GameInstance.GetTransactionSystem(owner.GetGame()).GetEmptySlotsOnItem(owner, itemID, attachmentSlotList);
    quality = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemData(owner, itemID).GetStatValueByType(gamedataStatType.Quality);
    index = 0;
    while index < ArraySize(attachmentSlotList) && index < 4 {
      if this.IsGenericWeaponMod(attachmentSlotList[index], Cast(quality)) {
        return false;
      };
      index += 1;
    };
    return true;
  }

  public final const func IsGenericWeaponMod(tweakDBID: TweakDBID, quality: Int32) -> Bool {
    let weaponModSlotIDs: TweakDBID[4];
    weaponModSlotIDs[0] = t"AttachmentSlots.GenericWeaponMod1";
    weaponModSlotIDs[1] = t"AttachmentSlots.GenericWeaponMod2";
    weaponModSlotIDs[2] = t"AttachmentSlots.GenericWeaponMod3";
    weaponModSlotIDs[3] = t"AttachmentSlots.GenericWeaponMod4";
    let index: Int32 = 0;
    while index < quality {
      if tweakDBID == weaponModSlotIDs[index] {
        return true;
      };
      index = index + 1;
    };
    return false;
  }
}

public class ItemInSlotCallback extends AttachmentSlotsScriptCallback {

  protected let m_state: wref<ItemInSlotPrereqState>;

  public func OnItemEquipped(slot: TweakDBID, item: ItemID) -> Void {
    this.m_state.SlotFilled(slot, item);
  }

  public func OnItemUnequipped(slot: TweakDBID, item: ItemID) -> Void {
    this.m_state.SlotEmptied(slot, item);
  }

  public final func RegisterState(state: ref<PrereqState>) -> Void {
    this.m_state = state as ItemInSlotPrereqState;
  }
}
