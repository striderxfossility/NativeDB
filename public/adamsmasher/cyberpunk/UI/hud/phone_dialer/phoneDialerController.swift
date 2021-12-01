
public class PhoneDialerGameController extends inkHUDGameController {

  private edit let m_contactsList: inkWidgetRef;

  private edit let m_avatarImage: inkImageRef;

  private edit let m_hintMessenger: inkWidgetRef;

  private edit let m_scrollArea: inkScrollAreaRef;

  private edit let m_scrollControllerWidget: inkWidgetRef;

  private let m_journalManager: ref<JournalManager>;

  private let m_phoneSystem: wref<PhoneSystem>;

  private let m_active: Bool;

  private let m_listController: wref<inkVirtualListController>;

  private let m_dataSource: ref<ScriptableDataSource>;

  private let m_dataView: ref<DialerContactDataView>;

  private let m_templateClassifier: ref<DialerContactTemplateClassifier>;

  private let m_scrollController: wref<inkScrollController>;

  @default(PhoneDialerGameController, Phone)
  private edit let m_soundName: CName;

  @default(PhoneDialerGameController, ui_phone_navigation)
  private edit let m_audioPhoneNavigation: CName;

  private let m_phoneBlackboard: wref<IBlackboard>;

  private let m_phoneBBDefinition: ref<UI_ComDeviceDef>;

  private let m_contactOpensBBID: ref<CallbackHandle>;

  private let m_switchAnimProxy: ref<inkAnimProxy>;

  private let m_transitionAnimProxy: ref<inkAnimProxy>;

  @default(PhoneDialerGameController, false)
  private let m_repeatingScrollActionEnabled: Bool;

  private let m_firstInit: Bool;

  protected cb func OnInitialize() -> Bool {
    let owner: wref<GameObject> = this.GetPlayerControlledObject();
    let gameInstance: GameInstance = owner.GetGame();
    this.m_journalManager = GameInstance.GetJournalManager(gameInstance);
    this.m_phoneSystem = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"PhoneSystem") as PhoneSystem;
    this.m_phoneBBDefinition = GetAllBlackboardDefs().UI_ComDevice;
    this.m_phoneBlackboard = this.GetBlackboardSystem().Get(this.m_phoneBBDefinition);
    this.m_contactOpensBBID = this.m_phoneBlackboard.RegisterDelayedListenerBool(this.m_phoneBBDefinition.ContactsActive, this, n"OnPhoneStateChanged");
    this.GetRootWidget().SetVisible(false);
    this.InitVirtualList();
    PopupStateUtils.SetBackgroundBlurBlendTime(this, 0.10);
    inkWidgetRef.RegisterToCallback(this.m_scrollArea, n"OnScrollChanged", this, n"OnScrollChanged");
    this.m_scrollController = inkWidgetRef.GetControllerByType(this.m_scrollControllerWidget, n"inkScrollController") as inkScrollController;
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_phoneBlackboard.UnregisterDelayedListener(this.m_phoneBBDefinition.ContactsActive, this.m_contactOpensBBID);
    this.CleanVirtualList();
    this.CloseContactList();
    this.Hide();
  }

  protected cb func OnScrollChanged(value: Vector2) -> Bool {
    this.m_scrollController.UpdateScrollPositionFromScrollArea();
  }

  protected cb func OnPhoneStateChanged(value: Bool) -> Bool {
    if NotEquals(this.m_active, value) {
      this.m_active = value;
      this.m_active ? this.Show() : this.Hide();
    };
  }

  private final func InitVirtualList() -> Void {
    this.m_templateClassifier = new DialerContactTemplateClassifier();
    this.m_dataView = new DialerContactDataView();
    this.m_dataSource = new ScriptableDataSource();
    this.m_dataView.Setup();
    this.m_dataView.SetSource(this.m_dataSource);
    this.m_listController = inkWidgetRef.GetControllerByType(this.m_contactsList, n"inkVirtualListController") as inkVirtualListController;
    this.m_listController.SetClassifier(this.m_templateClassifier);
    this.m_listController.SetSource(this.m_dataView);
    this.m_listController.RegisterToCallback(n"OnItemSelected", this, n"OnItemSelected");
    this.m_listController.RegisterToCallback(n"OnAllElementsSpawned", this, n"OnAllElementsSpawned");
  }

  private final func CleanVirtualList() -> Void {
    this.m_listController.SetSource(null);
    this.m_listController.SetClassifier(null);
    this.m_dataView.SetSource(null);
    this.m_dataView = null;
    this.m_dataSource = null;
    this.m_templateClassifier = null;
  }

  protected cb func OnItemSelected(previous: ref<inkVirtualCompoundItemController>, next: ref<inkVirtualCompoundItemController>) -> Bool {
    let contactData: ref<ContactData> = FromVariant(next.GetData()) as ContactData;
    InkImageUtils.RequestSetImage(this, this.m_avatarImage, contactData.avatarID);
    if IsDefined(this.m_switchAnimProxy) {
      this.m_switchAnimProxy.Stop();
      this.m_switchAnimProxy = null;
    };
    this.m_switchAnimProxy = this.PlayLibraryAnimation(n"switchContact");
    inkWidgetRef.SetVisible(this.m_hintMessenger, contactData.playerCanReply || contactData.hasMessages);
  }

  private final func Show() -> Void {
    let player: ref<GameObject> = this.GetPlayerControlledObject();
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(player.GetGame());
    uiSystem.PushGameContext(UIGameContext.ModalPopup);
    uiSystem.RequestNewVisualState(n"inkModalPopupState");
    TimeDilationHelper.SetTimeDilationWithProfile(player, "radialMenu", true);
    player.RegisterInputListener(this, n"popup_moveDown");
    player.RegisterInputListener(this, n"popup_moveUp");
    player.RegisterInputListener(this, n"popup_goto");
    player.RegisterInputListener(this, n"OpenPauseMenu");
    player.RegisterInputListener(this, n"proceed");
    player.RegisterInputListener(this, n"cancel");
    this.GetRootWidget().SetVisible(true);
    this.PopulateData();
    if IsDefined(this.m_transitionAnimProxy) {
      this.m_transitionAnimProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnHideAnimFinished");
      this.m_transitionAnimProxy.Stop();
      this.m_transitionAnimProxy = null;
    };
    this.m_transitionAnimProxy = this.PlayLibraryAnimation(n"fadeIn");
    this.PlaySound(n"Holocall", n"OnPickingUp");
    PopupStateUtils.SetBackgroundBlur(this, true);
  }

  private final func Hide() -> Void {
    let player: ref<GameObject> = this.GetPlayerControlledObject();
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(player.GetGame());
    uiSystem.PopGameContext(UIGameContext.ModalPopup);
    uiSystem.RestorePreviousVisualState(n"inkModalPopupState");
    player.UnregisterInputListener(this);
    TimeDilationHelper.SetTimeDilationWithProfile(player, "radialMenu", false);
    this.GetRootWidget().SetVisible(false);
    this.PlaySound(n"Holocall", n"OnHangUp");
    PopupStateUtils.SetBackgroundBlur(this, false);
    this.m_repeatingScrollActionEnabled = false;
  }

  protected cb func OnHideAnimFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.GetRootWidget().SetVisible(false);
  }

  protected cb func OnAllElementsSpawned() -> Bool {
    if this.m_firstInit {
      this.m_firstInit = false;
      this.m_listController.SelectItem(0u);
    };
  }

  private final func PopulateData() -> Void {
    let contactDataArray: array<ref<IScriptable>> = this.m_journalManager.GetContactDataArray(false);
    this.m_dataView.EnableSorting();
    this.m_dataSource.Reset(contactDataArray);
    this.m_dataView.DisableSorting();
    this.m_firstInit = true;
  }

  private final func CallSelectedContact() -> Void {
    let callRequest: ref<questTriggerCallRequest>;
    let item: ref<PhoneContactItemVirtualController> = this.m_listController.GetSelectedItem() as PhoneContactItemVirtualController;
    let contactData: ref<ContactData> = item.GetContactData();
    if IsDefined(contactData) {
      callRequest = new questTriggerCallRequest();
      callRequest.addressee = StringToName(contactData.id);
      callRequest.caller = n"Player";
      callRequest.callPhase = questPhoneCallPhase.IncomingCall;
      callRequest.callMode = questPhoneCallMode.Video;
      this.m_phoneSystem.QueueRequest(callRequest);
    };
  }

  private final func CloseContactList() -> Void {
    if IsDefined(this.m_phoneBlackboard) {
      this.m_phoneBlackboard.SetBool(this.m_phoneBBDefinition.ContactsActive, false, true);
    };
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let handled: Bool = false;
    let actionName: CName = ListenerAction.GetName(action);
    if Equals(ListenerAction.GetType(action), gameinputActionType.REPEAT) {
      if !this.m_repeatingScrollActionEnabled {
        return false;
      };
      switch actionName {
        case n"popup_moveDown":
          this.m_listController.Navigate(inkDiscreteNavigationDirection.Down);
          handled = true;
          break;
        case n"popup_moveUp":
          this.m_listController.Navigate(inkDiscreteNavigationDirection.Up);
          handled = true;
      };
    } else {
      if Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_PRESSED) {
        actionName = ListenerAction.GetName(action);
        if !this.m_repeatingScrollActionEnabled {
          this.m_repeatingScrollActionEnabled = true;
        };
        switch actionName {
          case n"popup_moveDown":
            this.m_listController.Navigate(inkDiscreteNavigationDirection.Down);
            handled = true;
            break;
          case n"popup_moveUp":
            this.m_listController.Navigate(inkDiscreteNavigationDirection.Up);
            handled = true;
            break;
          case n"proceed":
            this.CallSelectedContact();
            handled = true;
            break;
          case n"OpenPauseMenu":
            ListenerActionConsumer.DontSendReleaseEvent(consumer);
            this.CloseContactList();
            handled = true;
            break;
          case n"cancel":
            this.CloseContactList();
            handled = true;
            break;
          case n"popup_goto":
            if inkWidgetRef.IsVisible(this.m_hintMessenger) {
              this.GotoMessengerMenu();
              this.CloseContactList();
            };
            handled = true;
        };
      };
    };
    if handled {
      this.PlaySound(n"Holocall", n"Navigation");
    };
  }

  private final func GotoMessengerMenu() -> Void {
    let evt: ref<StartHubMenuEvent>;
    let userData: ref<MessageMenuAttachmentData>;
    let item: ref<PhoneContactItemVirtualController> = this.m_listController.GetSelectedItem() as PhoneContactItemVirtualController;
    let contactData: ref<ContactData> = item.GetContactData();
    if contactData.playerCanReply || contactData.hasMessages {
      userData = new MessageMenuAttachmentData();
      userData.m_entryHash = contactData.hash;
      evt = new StartHubMenuEvent();
      evt.SetStartMenu(n"phone", userData);
      this.QueueBroadcastEvent(evt);
    };
  }
}
