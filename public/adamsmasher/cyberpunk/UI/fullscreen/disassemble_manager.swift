
public class DisassembleManager extends gameuiMenuGameController {

  private edit let m_listRef: inkCompoundRef;

  @default(DisassembleManager, 1.0)
  private edit let m_initialPopupDelay: Float;

  private let m_popupList: array<wref<DisassemblePopupLogicController>>;

  private let m_listOfAddedInventoryItems: array<InventoryItemData>;

  private let m_player: wref<PlayerPuppet>;

  private let m_InventoryManager: ref<InventoryDataManagerV2>;

  private let m_transactionSystem: ref<TransactionSystem>;

  private let m_root: wref<inkWidget>;

  private let m_animProxy: ref<inkAnimProxy>;

  private let m_alpha_fadein: ref<inkAnimDef>;

  private let m_AnimOptions: inkAnimOptions;

  private let m_DisassembleCallback: ref<UI_CraftingDef>;

  private let m_DisassembleBlackboard: wref<IBlackboard>;

  private let m_DisassembleBBID: ref<CallbackHandle>;

  private let m_CraftingBBID: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    this.m_player = this.GetOwnerEntity() as PlayerPuppet;
    this.m_InventoryManager = new InventoryDataManagerV2();
    this.m_InventoryManager.Initialize(this.m_player);
    this.m_transactionSystem = GameInstance.GetTransactionSystem(this.m_player.GetGame());
    inkCompoundRef.RemoveAllChildren(this.m_listRef);
    this.SetupBB();
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_InventoryManager.UnInitialize();
    this.UnregisterFromBB();
  }

  private final func SetupBB() -> Void {
    this.m_DisassembleCallback = GetAllBlackboardDefs().UI_Crafting;
    this.m_DisassembleBlackboard = this.GetBlackboardSystem().Get(this.m_DisassembleCallback);
    if IsDefined(this.m_DisassembleBlackboard) {
      this.m_DisassembleBBID = this.m_DisassembleBlackboard.RegisterDelayedListenerVariant(this.m_DisassembleCallback.lastIngredients, this, n"OnDisassembleComplete", true);
    };
  }

  private final func UnregisterFromBB() -> Void {
    if IsDefined(this.m_DisassembleBlackboard) {
      this.m_DisassembleBlackboard.UnregisterDelayedListener(this.m_DisassembleCallback.lastIngredients, this.m_DisassembleBBID);
    };
  }

  public final func ManagePopups() -> Void {
    if ArraySize(this.m_listOfAddedInventoryItems) > 0 {
      this.CreatePopup();
      this.CreatePopupDelay();
    };
  }

  private final func CreatePopup() -> Void {
    let popup: wref<DisassemblePopupLogicController> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_listRef), n"disassemble_popup").GetController() as DisassemblePopupLogicController;
    popup.SetupData(ArrayPop(this.m_listOfAddedInventoryItems));
    popup.RegisterToCallback(n"OnPopupComplete", this, n"OnRemovePopup");
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

  protected cb func OnDisassembleComplete(value: Variant) -> Bool {
    let i: Int32;
    let itemID: ItemID;
    let itemRecord: ref<Item_Record>;
    let itemdata: wref<gameItemData>;
    let tempData: InventoryItemData;
    let disassembledIngredientData: array<IngredientData> = FromVariant(value);
    if ArraySize(disassembledIngredientData) > 0 {
      i = 0;
      while i < ArraySize(disassembledIngredientData) {
        if disassembledIngredientData[i].itemAmount > 0 {
          itemRecord = disassembledIngredientData[i].id;
          itemID = ItemID.FromTDBID(itemRecord.GetID());
          itemdata = GameInstance.GetTransactionSystem(this.m_player.GetGame()).GetItemData(this.m_player, itemID);
          tempData = this.m_InventoryManager.GetInventoryItemData(itemdata);
          ArrayPush(this.m_listOfAddedInventoryItems, tempData);
          GameInstance.GetActivityLogSystem((this.GetPlayerControlledObject() as PlayerPuppet).GetGame()).AddLog(GetLocalizedText("UI-ScriptExports-Looted") + ": " + UIItemsHelper.GetItemName(itemRecord, itemdata));
        };
        i += 1;
      };
    };
  }

  protected cb func OnRemovePopup(widget: wref<inkWidget>) -> Bool {
    inkCompoundRef.RemoveChild(this.m_listRef, widget);
    this.ManagePopups();
  }

  protected cb func OnDelayComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.ManagePopups();
  }
}

public class DisassemblePopupLogicController extends inkLogicController {

  private edit let m_quantity: inkTextRef;

  private edit let m_icon: inkImageRef;

  private edit let m_label: inkTextRef;

  @default(DisassemblePopupLogicController, 3.0f)
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
