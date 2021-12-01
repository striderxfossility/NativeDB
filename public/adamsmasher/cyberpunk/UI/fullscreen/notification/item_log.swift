
public class ItemLog extends gameuiMenuGameController {

  private edit let m_listRef: inkCompoundRef;

  @default(ItemLog, 1.0)
  private edit let m_initialPopupDelay: Float;

  private let m_popupList: array<wref<DisassemblePopupLogicController>>;

  private let m_listOfAddedInventoryItems: array<InventoryItemData>;

  private let m_player: wref<PlayerPuppet>;

  private let m_InventoryManager: ref<InventoryDataManagerV2>;

  private let m_data: ref<ItemLogUserData>;

  private let m_onScreenCount: Int32;

  private let m_animProxy: ref<inkAnimProxy>;

  private let m_alpha_fadein: ref<inkAnimDef>;

  private let m_AnimOptions: inkAnimOptions;

  protected cb func OnInitialize() -> Bool {
    this.m_player = this.GetOwnerEntity() as PlayerPuppet;
    this.m_InventoryManager = new InventoryDataManagerV2();
    this.m_InventoryManager.Initialize(this.m_player);
    inkCompoundRef.RemoveAllChildren(this.m_listRef);
    this.m_data = this.GetRootWidget().GetUserData(n"ItemLogUserData") as ItemLogUserData;
    this.m_data.token.RegisterListener(this, n"OnItemAdded");
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_InventoryManager.UnInitialize();
  }

  public final func ManagePopups() -> Void {
    let userData: ref<ItemLogUserData>;
    if ArraySize(this.m_listOfAddedInventoryItems) == 0 && this.m_onScreenCount <= 0 {
      userData = new ItemLogUserData();
      userData.itemLogQueueEmpty = true;
      this.m_data.token.TriggerCallback(userData);
    };
    if ArraySize(this.m_listOfAddedInventoryItems) > 0 && this.m_onScreenCount <= 3 && !this.m_animProxy.IsPlaying() {
      this.CreatePopup();
      this.CreatePopupDelay();
    };
  }

  private final func CreatePopup() -> Void {
    let popup: wref<ItemLogPopupLogicController> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_listRef), n"itemLog_popup").GetController() as ItemLogPopupLogicController;
    popup.SetupData(ArrayPop(this.m_listOfAddedInventoryItems));
    popup.RegisterToCallback(n"OnPopupComplete", this, n"OnRemovePopup");
    this.m_onScreenCount += 1;
  }

  private final func CreatePopupDelay() -> Void {
    this.m_alpha_fadein = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetDuration(this.m_initialPopupDelay);
    alphaInterpolator.SetStartTransparency(1.00);
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_alpha_fadein.AddInterpolator(alphaInterpolator);
    this.m_animProxy = inkWidgetRef.PlayAnimation(this.m_listRef, this.m_alpha_fadein);
    this.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnDelayComplete");
  }

  protected cb func OnItemAdded(data: ref<inkGameNotificationData>) -> Bool {
    let itemdata: wref<gameItemData>;
    let tempData: InventoryItemData;
    let userData: ref<ItemLogUserData> = data as ItemLogUserData;
    let itemID: ItemID = userData.itemID;
    if userData.itemLogQueueEmpty {
      return false;
    };
    if ItemID.IsValid(itemID) {
      itemdata = GameInstance.GetTransactionSystem(this.m_player.GetGame()).GetItemData(this.m_player, itemID);
      tempData = this.m_InventoryManager.GetInventoryItemData(itemdata);
      if !InventoryDataManagerV2.IsItemBlacklisted(itemdata) {
        ArrayPush(this.m_listOfAddedInventoryItems, tempData);
        this.ManagePopups();
      };
    };
  }

  protected cb func OnRemovePopup(widget: wref<inkWidget>) -> Bool {
    inkCompoundRef.RemoveChild(this.m_listRef, widget);
    this.m_onScreenCount -= 1;
    this.ManagePopups();
  }

  protected cb func OnDelayComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.ManagePopups();
  }
}

public class ItemLogPopupLogicController extends inkLogicController {

  private edit let m_quantity: inkTextRef;

  private edit let m_icon: inkImageRef;

  private edit let m_label: inkTextRef;

  @default(ItemLogPopupLogicController, 3.0f)
  private edit let m_duration: Float;

  private let m_animProxy: ref<inkAnimProxy>;

  private let m_alpha_fadein: ref<inkAnimDef>;

  private let m_AnimOptions: inkAnimOptions;

  protected cb func OnInitialize() -> Bool;

  public final func SetupData(itemData: InventoryItemData) -> Void {
    inkTextRef.SetText(this.m_label, InventoryItemData.GetName(itemData));
    inkTextRef.SetText(this.m_quantity, "x" + ToString(InventoryItemData.GetQuantity(itemData)));
    inkImageRef.SetTexturePart(this.m_icon, StringToName(InventoryItemData.GetIconPath(itemData)));
    this.m_animProxy = this.PlayLibraryAnimation(n"AddPopup");
    this.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAddPopupComplete");
  }

  protected cb func OnAddPopupComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.m_alpha_fadein = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetDuration(this.m_duration);
    alphaInterpolator.SetStartTransparency(1.00);
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_alpha_fadein.AddInterpolator(alphaInterpolator);
    this.m_animProxy = inkWidgetRef.PlayAnimation(this.m_quantity, this.m_alpha_fadein);
    this.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnPopupDurationComplete");
  }

  protected cb func OnPopupDurationComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.CallCustomCallback(n"OnPopupComplete");
  }
}
