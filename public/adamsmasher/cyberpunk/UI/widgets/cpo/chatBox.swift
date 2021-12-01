
public native class gameuiChatBoxGameController extends inkHUDGameController {

  private let m_player: wref<gamePuppetBase>;

  private let m_chatBoxBlackboardId: ref<CallbackHandle>;

  private edit let m_chatBox: inkWidgetRef;

  private edit let m_enteredText: inkTextInputRef;

  private let m_chatBoxOpen: Bool;

  private let m_recentChatsShown: array<wref<inkWidget>>;

  private edit let m_recentContainer: wref<inkVerticalPanel>;

  private edit let m_historyContainer: wref<inkVerticalPanel>;

  private let m_chatHistory: array<ChatBoxText>;

  private let m_lastChatId: Int32;

  @default(gameuiChatBoxGameController, 7)
  private let maxChatsDisplayed: Int32;

  @default(gameuiChatBoxGameController, 100)
  private let maxChatHistory: Int32;

  protected cb func OnInitialize() -> Bool {
    let chatBoxBB: ref<IBlackboard>;
    this.m_chatBoxOpen = false;
    this.m_lastChatId = -1;
    this.m_player = this.GetOwnerEntity() as gamePuppetBase;
    this.m_player.RegisterInputListener(this, n"OpenChatBox");
    this.m_player.RegisterInputListener(this, n"EnterChat");
    this.m_player.RegisterInputListener(this, n"UI_Cancel");
    chatBoxBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ChatBox);
    this.m_chatBoxBlackboardId = chatBoxBB.RegisterListenerVariant(GetAllBlackboardDefs().UI_ChatBox.TextList, this, n"OnChatAdded");
    this.SetMaxEnteredChars(inkWidgetRef.Get(this.m_enteredText) as inkTextInput);
    inkWidgetRef.SetVisible(this.m_chatBox, false);
    this.m_recentContainer = this.GetWidget(n"RecentHolder/Recent") as inkVerticalPanel;
    this.m_historyContainer = this.GetWidget(n"ChatBox/HistoryHolder/History") as inkVerticalPanel;
  }

  protected cb func OnChatAdded(value: Variant) -> Bool {
    let chatList: array<ChatBoxText> = FromVariant(value);
    let i: Int32 = 0;
    while i < ArraySize(chatList) {
      if chatList[i].id > this.m_lastChatId {
        this.m_lastChatId = chatList[i].id;
        ArrayInsert(this.m_chatHistory, 0, chatList[i]);
        if ArraySize(this.m_chatHistory) > this.maxChatHistory {
          ArrayPop(this.m_chatHistory);
        };
        this.DisplayChat(chatList[i]);
      };
      i += 1;
    };
    if this.m_chatBoxOpen {
      this.ShowHistory();
    };
  }

  private final func DisplayChat(chatBoxText: ChatBoxText) -> Void {
    let chatPanel: wref<inkWidget> = this.SpawnFromLocal(this.m_recentContainer, n"TextSection");
    let controller: wref<TextSectionLogicController> = chatPanel.GetController() as TextSectionLogicController;
    controller.Show(chatBoxText);
    controller.RegisterToCallback(n"OnReadyToRemove", this, n"OnHideRecentChat");
    controller.StartFadeOut();
    ArrayInsert(this.m_recentChatsShown, 0, chatPanel);
    if ArraySize(this.m_recentChatsShown) > this.maxChatsDisplayed {
      chatPanel = ArrayPop(this.m_recentChatsShown);
      this.m_recentContainer.RemoveChild(chatPanel);
    };
  }

  private final func DisplayHistory(chatBoxText: ChatBoxText) -> Void {
    let chatPanel: wref<inkWidget> = this.SpawnFromLocal(this.m_historyContainer, n"TextSection");
    let controller: wref<TextSectionLogicController> = chatPanel.GetController() as TextSectionLogicController;
    controller.Show(chatBoxText);
  }

  protected cb func OnHideRecentChat(chatItem: wref<inkWidget>) -> Bool {
    ArrayRemove(this.m_recentChatsShown, chatItem);
    this.m_recentContainer.RemoveChild(chatItem);
  }

  protected cb func OnUninitialize() -> Bool {
    let chatBoxBB: ref<IBlackboard>;
    if IsDefined(this.m_chatBoxBlackboardId) {
      chatBoxBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ChatBox);
      chatBoxBB.UnregisterListenerVariant(GetAllBlackboardDefs().UI_ChatBox.TextList, this.m_chatBoxBlackboardId);
    };
  }

  private final native func UpdateInputContext(isChatBoxContext: Bool) -> Void;

  private final native func SetMaxEnteredChars(enteredText: wref<inkTextInput>) -> Void;

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let actionName: CName = ListenerAction.GetName(action);
    let actionType: gameinputActionType = ListenerAction.GetType(action);
    if !this.m_chatBoxOpen && Equals(actionName, n"OpenChatBox") && Equals(actionType, gameinputActionType.BUTTON_PRESSED) {
      this.ShowChatBox(true);
      this.ShowHistory();
    } else {
      if this.m_chatBoxOpen && Equals(actionName, n"EnterChat") && Equals(actionType, gameinputActionType.BUTTON_PRESSED) {
        this.SendChat();
        this.ShowChatBox(false);
      } else {
        if this.m_chatBoxOpen && Equals(actionName, n"UI_Cancel") && Equals(actionType, gameinputActionType.BUTTON_PRESSED) {
          this.ShowChatBox(false);
        };
      };
    };
  }

  private final func ShowChatBox(show: Bool) -> Void {
    let widgetToFocus: wref<inkWidget>;
    let enteredText: wref<inkTextInput> = inkWidgetRef.Get(this.m_enteredText) as inkTextInput;
    this.m_chatBoxOpen = show;
    enteredText.SetText("");
    inkWidgetRef.SetVisible(this.m_chatBox, show);
    widgetToFocus = show ? inkWidgetRef.Get(this.m_enteredText) : null;
    this.RequestSetFocus(widgetToFocus);
    if !show {
      this.m_historyContainer.RemoveAllChildren();
    };
    this.m_historyContainer.SetVisible(show);
    this.m_recentContainer.SetVisible(!show);
    this.UpdateInputContext(show);
  }

  private final func ShowHistory() -> Void {
    let i: Int32;
    this.m_historyContainer.RemoveAllChildren();
    i = Min(this.maxChatsDisplayed - 1, ArraySize(this.m_chatHistory) - 1);
    while i >= 0 {
      this.DisplayHistory(this.m_chatHistory[i]);
      i -= 1;
    };
  }

  private final func SendChat() -> Void {
    let textEntered: String = inkWidgetRef.Get(this.m_enteredText) as inkTextInput.GetText();
    if NotEquals(textEntered, "") {
      GameInstance.GetGameRulesSystem(GetGameInstance()).SendChat(textEntered);
    };
  }
}

public class TextSectionLogicController extends inkLogicController {

  private let m_rootWidget: wref<inkWidget>;

  private let m_textWidget: wref<inkText>;

  private let m_showAnimProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_textWidget = this.GetWidget(n"Text") as inkText;
    this.m_rootWidget.SetAnchorPoint(new Vector2(0.50, 0.50));
    this.SetActive(false);
  }

  protected cb func OnUninitialize() -> Bool;

  private final func SetActive(active: Bool) -> Void {
    this.m_rootWidget.SetVisible(active);
  }

  public final func Show(chatBoxText: ChatBoxText) -> Void {
    this.m_textWidget.SetText(chatBoxText.text);
    this.m_textWidget.SetTintColor(chatBoxText.color);
    this.SetActive(true);
  }

  public final func StartFadeOut() -> Void {
    this.m_showAnimProxy = this.PlayLibraryAnimation(n"TextFade");
    this.m_showAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnHide");
  }

  protected cb func OnHide(anim: ref<inkAnimProxy>) -> Bool {
    this.SetActive(false);
    this.CallCustomCallback(n"OnReadyToRemove");
  }
}
