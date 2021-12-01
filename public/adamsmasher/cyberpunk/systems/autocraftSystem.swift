
public class AutocraftSystem extends ScriptableSystem {

  private let m_active: Bool;

  private let m_cycleDuration: Float;

  private let m_currentDelayID: DelayID;

  private let m_itemsUsed: array<ItemID>;

  private final func OnSystemActivate(request: ref<AutocraftActivateRequest>) -> Void {
    let endCycleRequest: ref<AutocraftEndCycleRequest> = new AutocraftEndCycleRequest();
    if this.m_active {
      return;
    };
    this.m_active = true;
    this.m_currentDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"AutocraftSystem", endCycleRequest, this.m_cycleDuration);
  }

  private final func OnSystemDeactivate(request: ref<AutocraftDeactivateRequest>) -> Void {
    if !this.m_active {
      return;
    };
    this.m_active = false;
    if request.resetMemory {
      ArrayClear(this.m_itemsUsed);
    };
    GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_currentDelayID);
  }

  private final func OnCycleEnd(request: ref<AutocraftEndCycleRequest>) -> Void {
    let i: Int32;
    let itemsToAutocraft: array<ItemID>;
    let endCycleRequest: ref<AutocraftEndCycleRequest> = new AutocraftEndCycleRequest();
    if !this.m_active {
      return;
    };
    itemsToAutocraft = this.GetItemsToAutocraft();
    i = 0;
    while i < ArraySize(itemsToAutocraft) {
      GameInstance.GetTransactionSystem(this.GetGameInstance()).GiveItem(GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject(), itemsToAutocraft[i], 1);
      ArrayErase(this.m_itemsUsed, ArrayFindLast(this.m_itemsUsed, itemsToAutocraft[i]));
      GameInstance.GetActivityLogSystem(this.GetGameInstance()).AddLog("Flathead autocrafted item " + TDBID.ToStringDEBUG(ItemID.GetTDBID(itemsToAutocraft[i])) + ".");
      i += 1;
    };
    this.m_currentDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"AutocraftSystem", endCycleRequest, this.m_cycleDuration);
  }

  private final func GetItemsToAutocraft() -> array<ItemID> {
    let itemsToAutocraft: array<ItemID>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_itemsUsed) {
      if !ArrayContains(itemsToAutocraft, this.m_itemsUsed[i]) {
        ArrayPush(itemsToAutocraft, this.m_itemsUsed[i]);
      };
      i += 1;
    };
    return itemsToAutocraft;
  }

  private final func OnItemUsed(request: ref<RegisterItemUsedRequest>) -> Void {
    let itemTags: array<CName>;
    if !this.m_active {
      return;
    };
    itemTags = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(request.itemUsed)).Tags();
    if ArrayContains(itemTags, n"Quest") {
      return;
    };
    ArrayPush(this.m_itemsUsed, request.itemUsed);
  }
}
