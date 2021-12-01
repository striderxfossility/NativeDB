
public class BaseCodexLinkController extends inkLogicController {

  protected edit let m_linkImage: inkImageRef;

  protected edit let m_linkLabel: inkTextRef;

  protected let m_animProxy: ref<inkAnimProxy>;

  protected let m_isInteractive: Bool;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    this.RegisterToCallback(n"OnRelease", this, n"OnRelease");
    this.m_isInteractive = true;
  }

  protected cb func OnHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    if this.m_isInteractive {
      this.ForcePlayAnimation(n"hyperlink_hover");
    };
  }

  protected cb func OnHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    if this.m_isInteractive {
      this.ForcePlayAnimation(n"clear_hyperlink_hover");
    };
  }

  protected cb func OnRelease(e: ref<inkPointerEvent>) -> Bool {
    if this.m_isInteractive {
      if e.IsAction(n"click") {
        this.Activate();
      } else {
        if e.IsAction(n"activate") {
          this.ActivateSecondary();
        };
      };
    };
  }

  private func Activate() -> Void;

  private func ActivateSecondary() -> Void;

  private final func ForcePlayAnimation(animationName: CName) -> Void {
    if this.m_animProxy.IsPlaying() {
      this.m_animProxy.Stop();
    };
    this.m_animProxy = this.PlayLibraryAnimationOnAutoSelectedTargets(animationName, this.GetRootWidget());
  }
}

public class QuestCodexLinkController extends BaseCodexLinkController {

  protected edit let m_linkLabelContainer: inkWidgetRef;

  private let m_journalEntry: ref<JournalEntry>;

  public final func Setup(journalEntry: ref<JournalEntry>) -> Void {
    let codexEntry: ref<JournalCodexEntry>;
    this.m_journalEntry = journalEntry;
    let imgEntry: ref<JournalImageEntry> = journalEntry as JournalImageEntry;
    if IsDefined(imgEntry) {
      this.SetupImageLink(imgEntry);
    } else {
      codexEntry = journalEntry as JournalCodexEntry;
      this.SetupCodexLink(codexEntry);
    };
  }

  private final func SetupCodexLink(codexEntry: ref<JournalCodexEntry>) -> Void {
    inkTextRef.SetText(this.m_linkLabel, codexEntry.GetTitle());
    inkWidgetRef.SetVisible(this.m_linkLabel, true);
    if TDBID.IsValid(codexEntry.GetImageID()) {
      InkImageUtils.RequestSetImage(this, this.m_linkImage, codexEntry.GetLinkImageID(), n"OnCallback");
    };
    this.GetRootWidget().SetInteractive(true);
  }

  private final func SetupImageLink(imageEntry: ref<JournalImageEntry>) -> Void {
    if TDBID.IsValid(imageEntry.GetThumbnailImageID()) {
      InkImageUtils.RequestSetImage(this, this.m_linkImage, imageEntry.GetThumbnailImageID());
    };
    this.m_isInteractive = TDBID.IsValid(imageEntry.GetImageID());
    if this.m_isInteractive {
      inkTextRef.SetLocalizedText(this.m_linkLabel, n"Common-Access-Open");
      inkWidgetRef.SetVisible(this.m_linkLabelContainer, true);
    } else {
      inkWidgetRef.SetVisible(this.m_linkLabelContainer, false);
    };
    this.GetRootWidget().SetInteractive(this.m_isInteractive);
  }

  private func Activate() -> Void {
    let evt: ref<OpenCodexPopupEvent>;
    if this.m_isInteractive {
      evt = new OpenCodexPopupEvent();
      evt.m_entry = this.m_journalEntry;
      this.QueueBroadcastEvent(evt);
    };
  }
}

public class QuestContactLinkController extends BaseCodexLinkController {

  private edit let m_msgLabel: inkTextRef;

  private edit let m_msgContainer: inkWidgetRef;

  private let m_msgCounter: Int32;

  private let m_contactEntry: ref<JournalContact>;

  private let m_journalMgr: wref<JournalManager>;

  private let m_phoneSystem: wref<PhoneSystem>;

  public final func Setup(journalEntry: ref<JournalEntry>, journalManager: wref<JournalManager>, phoneSystem: wref<PhoneSystem>) -> Void {
    let avatarTweakId: TweakDBID;
    this.m_phoneSystem = phoneSystem;
    this.m_journalMgr = journalManager;
    this.m_contactEntry = journalEntry as JournalContact;
    inkTextRef.SetText(this.m_linkLabel, this.m_contactEntry.GetLocalizedName(journalManager));
    avatarTweakId = this.m_contactEntry.GetAvatarID(journalManager);
    if TDBID.IsValid(avatarTweakId) {
      InkImageUtils.RequestSetImage(this, this.m_linkImage, avatarTweakId);
    };
    this.m_msgCounter = MessengerUtils.GetUnreadMessagesCount(journalManager, this.m_contactEntry);
    if this.m_msgCounter > 0 {
      inkTextRef.SetText(this.m_msgLabel, ToString(this.m_msgCounter));
      inkWidgetRef.SetVisible(this.m_msgContainer, true);
    } else {
      inkWidgetRef.SetVisible(this.m_msgContainer, false);
    };
  }

  private func Activate() -> Void {
    this.CallSelectedContact();
    this.CloseHubMenu();
  }

  private func ActivateSecondary() -> Void;

  private final func CloseHubMenu() -> Void {
    let evt: ref<ForceCloseHubMenuEvent> = new ForceCloseHubMenuEvent();
    this.QueueBroadcastEvent(evt);
  }

  private final func ShowMessenger() -> Void {
    let evt: ref<PhoneMessagePopupEvent> = new PhoneMessagePopupEvent();
    evt.m_data = new JournalNotificationData();
    evt.m_data.journalEntry = this.m_contactEntry;
    evt.m_data.queueName = n"modal_popup";
    evt.m_data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\phone_message_popup.inkwidget";
    evt.m_data.isBlocking = true;
    evt.m_data.useCursor = true;
    evt.m_data.menuMode = true;
    this.QueueBroadcastEvent(evt);
  }

  private final func CallSelectedContact() -> Void {
    let callRequest: ref<questTriggerCallRequest> = new questTriggerCallRequest();
    callRequest.addressee = StringToName(this.m_contactEntry.GetId());
    callRequest.caller = n"Player";
    callRequest.callPhase = questPhoneCallPhase.IncomingCall;
    callRequest.callMode = questPhoneCallMode.Video;
    this.m_phoneSystem.QueueRequest(callRequest);
  }
}

public class QuestMappinLinkController extends BaseCodexLinkController {

  private let m_mappinEntry: ref<JournalQuestMapPinBase>;

  private let m_jumpTo: Vector3;

  public final func Setup(mappinEntry: ref<JournalQuestMapPinBase>, jumpTo: Vector3) -> Void {
    this.m_mappinEntry = mappinEntry;
    inkTextRef.SetText(this.m_linkLabel, this.m_mappinEntry.GetCaption());
    this.m_jumpTo = jumpTo;
  }

  private func Activate() -> Void {
    let evt: ref<OpenMenuRequest> = new OpenMenuRequest();
    evt.m_menuName = n"world_map";
    let userData: ref<MapMenuUserData> = new MapMenuUserData();
    userData.m_moveTo = this.m_jumpTo;
    evt.m_eventData.userData = userData;
    evt.m_eventData.m_overrideDefaultUserData = true;
    evt.m_isMainMenu = true;
    this.QueueBroadcastEvent(evt);
  }
}
