
public class TarotMainGameController extends gameuiMenuGameController {

  protected edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_TooltipsManagerRef: inkWidgetRef;

  private edit let m_list: inkCompoundRef;

  protected let m_journalManager: wref<JournalManager>;

  private let buttonHintsController: wref<ButtonHints>;

  private let m_TooltipsManager: wref<gameuiTooltipsManager>;

  private let m_selectedTarotCard: wref<tarotCardLogicController>;

  private let m_fullscreenPreviewController: wref<TarotPreviewGameController>;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_tarotPreviewPopupToken: ref<inkGameNotificationToken>;

  private let m_afterCloseRequest: Bool;

  @default(TarotMainGameController, 22)
  private let numberOfCardsInTarotDeck: Int32;

  protected cb func OnInitialize() -> Bool {
    this.buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root").GetController() as ButtonHints;
    this.buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
    this.m_journalManager = GameInstance.GetJournalManager(this.GetPlayerControlledObject().GetGame());
    this.m_journalManager.RegisterScriptCallback(this, n"OnJournalReady", gameJournalListenerType.State);
    inkCompoundRef.RemoveAllChildren(this.m_list);
    this.PrepareTooltips();
    this.PushCodexData();
    this.PlayLibraryAnimation(n"panel_intro");
  }

  protected cb func OnUninitalize() -> Bool {
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnTarotCardPreviewShowRequest(evt: ref<TarotCardPreviewPopupEvent>) -> Bool {
    this.m_tarotPreviewPopupToken = this.ShowGameNotification(evt.m_data);
    this.m_tarotPreviewPopupToken.RegisterListener(this, n"OnTarotPreviewPopup");
  }

  protected cb func OnTarotPreviewPopup(data: ref<inkGameNotificationData>) -> Bool {
    this.m_tarotPreviewPopupToken = null;
  }

  protected cb func OnBack(userData: ref<IScriptable>) -> Bool {
    if !this.m_afterCloseRequest && !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") {
      this.m_menuEventDispatcher.SpawnEvent(n"OnCloseHubMenu");
    } else {
      this.m_afterCloseRequest = false;
    };
  }

  protected cb func OnJournalReady(entryHash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    let entryCodex: ref<JournalTarotGroup> = this.m_journalManager.GetEntry(entryHash) as JournalTarotGroup;
    if entryCodex != null {
      this.PushCodexData();
    };
  }

  private final func PushCodexData() -> Void {
    let cardFound: Bool;
    let data: TarotCardData;
    let dataArray: array<TarotCardData>;
    let entry: wref<JournalTarot>;
    let groupEntries: array<wref<JournalEntry>>;
    let i: Int32;
    let j: Int32;
    let journalContext: JournalRequestContext;
    let sortedArray: array<TarotCardData>;
    let tarotEntries: array<wref<JournalEntry>>;
    journalContext.stateFilter.active = true;
    this.m_journalManager.GetTarots(journalContext, groupEntries);
    i = 0;
    while i < ArraySize(groupEntries) {
      ArrayClear(tarotEntries);
      this.m_journalManager.GetChildren(groupEntries[i], journalContext.stateFilter, tarotEntries);
      i = 0;
      while i < ArraySize(tarotEntries) {
        entry = tarotEntries[i] as JournalTarot;
        data.empty = false;
        data.index = entry.GetIndex();
        data.imagePath = entry.GetImagePart();
        data.label = entry.GetName();
        data.desc = entry.GetDescription();
        ArrayPush(dataArray, data);
        i += 1;
      };
      i += 1;
    };
    i = 0;
    while i < this.numberOfCardsInTarotDeck {
      cardFound = false;
      j = 0;
      while j < ArraySize(dataArray) {
        if dataArray[j].index == i {
          ArrayPush(sortedArray, dataArray[j]);
          cardFound = true;
        } else {
          j += 1;
        };
      };
      if !cardFound {
        data.empty = true;
        data.index = i;
        data.imagePath = n"";
        data.label = "";
        data.desc = "";
        ArrayPush(sortedArray, data);
      };
      i += 1;
    };
    this.CreateTarotCards(sortedArray);
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_journalManager.UnregisterScriptCallback(this, n"OnJournalReady");
  }

  private final func CreateTarotCards(data: array<TarotCardData>) -> Void {
    let tarotCard: wref<tarotCardLogicController>;
    let i: Int32 = 0;
    while i < ArraySize(data) {
      tarotCard = this.SpawnFromLocal(inkWidgetRef.Get(this.m_list), n"tarotCard").GetController() as tarotCardLogicController;
      tarotCard.SetupData(data[i]);
      tarotCard.RegisterToCallback(n"OnRelease", this, n"OnElementClick");
      tarotCard.RegisterToCallback(n"OnHoverOver", this, n"OnElementHoverOver");
      tarotCard.RegisterToCallback(n"OnHoverOut", this, n"OnElementHoverOut");
      i += 1;
    };
  }

  protected cb func OnElementClick(evt: ref<inkPointerEvent>) -> Bool {
    let controller: wref<tarotCardLogicController>;
    let data: TarotCardData;
    let previewEvent: ref<TarotCardPreviewPopupEvent>;
    if evt.IsAction(n"click") {
      controller = this.GetTarotCardControllerFromTarget(evt);
      data = controller.GetData();
      if !data.empty {
        previewEvent = new TarotCardPreviewPopupEvent();
        previewEvent.m_data = new TarotCardPreviewData();
        previewEvent.m_data.cardData = data;
        previewEvent.m_data.queueName = n"modal_popup";
        previewEvent.m_data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\tarot_card_preview.inkwidget";
        previewEvent.m_data.isBlocking = true;
        previewEvent.m_data.useCursor = true;
        this.QueueBroadcastEvent(previewEvent);
        this.HideTooltips();
        this.m_selectedTarotCard.HoverOut();
      };
    };
  }

  protected cb func OnElementHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let controller: wref<tarotCardLogicController> = this.GetTarotCardControllerFromTarget(evt);
    let data: TarotCardData = controller.GetData();
    if !data.empty {
      this.RequestTooltip(controller.GetData());
    };
    this.m_selectedTarotCard = controller;
    this.m_selectedTarotCard.HoverOver();
  }

  protected cb func OnElementHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.HideTooltips();
    this.m_selectedTarotCard.HoverOut();
  }

  private final func PrepareTooltips() -> Void {
    this.m_TooltipsManager = inkWidgetRef.GetControllerByType(this.m_TooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    this.m_TooltipsManager.Setup(ETooltipsStyle.Menus);
  }

  private final func RequestTooltip(data: TarotCardData) -> Void {
    let toolTipData: ref<MessageTooltipData> = new MessageTooltipData();
    toolTipData.Title = data.label;
    toolTipData.Description = data.desc;
    this.m_TooltipsManager.ShowTooltip(toolTipData);
  }

  private final func HideTooltips() -> Void {
    this.m_TooltipsManager.HideTooltips();
  }

  private final func GetTarotCardControllerFromTarget(evt: ref<inkPointerEvent>) -> ref<tarotCardLogicController> {
    let widget: ref<inkWidget> = evt.GetCurrentTarget();
    let controller: wref<tarotCardLogicController> = widget.GetController() as tarotCardLogicController;
    return controller;
  }
}

public class tarotCardLogicController extends inkLogicController {

  private edit let m_image: inkImageRef;

  private edit let m_highlight: inkWidgetRef;

  private let m_data: TarotCardData;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.SetVisible(this.m_highlight, false);
  }

  public final func SetupData(data: TarotCardData) -> Void {
    this.m_data = data;
    if !this.m_data.empty {
      InkImageUtils.RequestSetImage(this, this.m_image, "UIIcon." + NameToString(this.m_data.imagePath));
    } else {
      InkImageUtils.RequestSetImage(this, this.m_image, t"UIIcon.TarotCard_Reverse");
    };
  }

  public final func HoverOver() -> Void {
    inkWidgetRef.SetVisible(this.m_highlight, true);
  }

  public final func HoverOut() -> Void {
    inkWidgetRef.SetVisible(this.m_highlight, false);
  }

  public final func GetData() -> TarotCardData {
    return this.m_data;
  }
}
