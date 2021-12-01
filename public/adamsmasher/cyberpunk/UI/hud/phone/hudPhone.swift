
public class HudPhoneGameController extends inkProjectedHUDGameController {

  private edit let m_AvatarControllerRef: inkWidgetRef;

  private let m_AvatarController: wref<HudPhoneAvatarController>;

  private let m_RootWidget: wref<inkWidget>;

  @default(HudPhoneGameController, OnOpen)
  private edit let m_SoundNameActionOnOpen: CName;

  @default(HudPhoneGameController, OnOpen)
  private edit let m_SoundNameActionOnClose: CName;

  @default(HudPhoneGameController, PhoneCallPopup)
  private edit let m_AudioInitiateCallPositiveEvent: CName;

  @default(HudPhoneGameController, PhoneCallPopup)
  private edit let m_AudioInitiateCallNegativeEvent: CName;

  @default(HudPhoneGameController, PhoneCallPopup)
  private edit let m_AudioInitiateCallEvent: CName;

  @default(HudPhoneGameController, PhoneCallPopup)
  private edit let m_AudioPhoneOnEvent: CName;

  @default(HudPhoneGameController, PhoneCallPopup)
  private edit let m_AudioPhoneOffEvent: CName;

  private edit let m_Holder: inkWidgetRef;

  private let m_Owner: wref<GameObject>;

  private let m_UnreadMessages: array<wref<JournalPhoneMessage>>;

  private let m_CurrentFunction: EHudPhoneFunction;

  private let m_CurrentCallInformation: PhoneCallInformation;

  private let m_CurrentPhoneCallContact: wref<JournalContact>;

  private let m_DelaySystem: wref<DelaySystem>;

  private let m_PhoneSystem: wref<PhoneSystem>;

  private let m_JournalMgr: wref<JournalManager>;

  private let m_gameplayRestrictions: array<CName>;

  private let m_Blackboard: wref<IBlackboard>;

  private let m_BlackboardDef: ref<UI_ComDeviceDef>;

  private let m_CallInformationBBID: ref<CallbackHandle>;

  private let m_StatusNameBBID: ref<CallbackHandle>;

  private let m_MinimizedListener: ref<CallbackHandle>;

  private let m_DelayedCallbackId: DelayID;

  private let m_DelayedTimeoutCallbackId: DelayID;

  @default(HudPhoneGameController, 8.0f)
  private let m_TimeoutPeroid: Float;

  private let portraitIntroAnim: ref<inkAnimProxy>;

  private let portraitOutroAnim: ref<inkAnimProxy>;

  private let portraitLoopAnim: ref<inkAnimProxy>;

  private let options: inkAnimOptions;

  private let m_updatesProjection: ref<inkScreenProjection>;

  private let m_buttonPressed: Bool;

  private final func CreateTriggerCallRequestFromPhoneCallInformation(phoneCallInformation: PhoneCallInformation) -> ref<questTriggerCallRequest> {
    let request: ref<questTriggerCallRequest> = new questTriggerCallRequest();
    request.callPhase = phoneCallInformation.callPhase;
    if phoneCallInformation.isAudioCall {
      request.callMode = questPhoneCallMode.Audio;
    } else {
      request.callMode = questPhoneCallMode.Video;
    };
    if phoneCallInformation.isPlayerCalling {
      request.caller = n"player";
      request.addressee = phoneCallInformation.contactName;
    } else {
      request.caller = phoneCallInformation.contactName;
      request.addressee = n"player";
    };
    return request;
  }

  protected cb func OnInitialize() -> Bool {
    let infoVariant: Variant;
    let lastPhoneCallInformation: PhoneCallInformation;
    let request: ref<questTriggerCallRequest>;
    this.m_RootWidget = this.GetRootWidget();
    this.m_AvatarController = inkWidgetRef.GetController(this.m_AvatarControllerRef) as HudPhoneAvatarController;
    this.m_Owner = this.GetPlayerControlledObject();
    this.CachePredefinedRestrictions();
    this.m_RootWidget.SetVisible(false);
    this.SetPhoneFunction(EHudPhoneFunction.Inactive);
    this.m_BlackboardDef = GetAllBlackboardDefs().UI_ComDevice;
    this.m_Blackboard = this.GetBlackboardSystem().Get(this.m_BlackboardDef);
    infoVariant = this.m_Blackboard.GetVariant(GetAllBlackboardDefs().UI_ComDevice.PhoneCallInformation);
    if VariantIsValid(infoVariant) {
      lastPhoneCallInformation = FromVariant(infoVariant);
      if Equals(lastPhoneCallInformation.callPhase, questPhoneCallPhase.IncomingCall) || Equals(lastPhoneCallInformation.callPhase, questPhoneCallPhase.StartCall) {
        request = this.CreateTriggerCallRequestFromPhoneCallInformation(lastPhoneCallInformation);
        GameInstance.GetScriptableSystemsContainer(this.m_Owner.GetGame()).QueueRequest(request);
      };
    };
    if IsDefined(this.m_Blackboard) {
      this.m_CallInformationBBID = this.m_Blackboard.RegisterDelayedListenerVariant(this.m_BlackboardDef.PhoneCallInformation, this, n"OnTriggerCall");
      this.m_StatusNameBBID = this.m_Blackboard.RegisterDelayedListenerName(this.m_BlackboardDef.comDeviceSetStatusText, this, n"OnPhoneStatusChanged");
      this.m_MinimizedListener = this.m_Blackboard.RegisterDelayedListenerBool(this.m_BlackboardDef.PhoneStyle_Minimized, this, n"OnPhoneMinimize");
    };
    this.m_JournalMgr = GameInstance.GetJournalManager(this.m_Owner.GetGame());
    this.m_DelaySystem = GameInstance.GetDelaySystem(this.m_Owner.GetGame());
    this.m_PhoneSystem = GameInstance.GetScriptableSystemsContainer(this.m_Owner.GetGame()).Get(n"PhoneSystem") as PhoneSystem;
    this.m_AvatarController.SetJournalManager(this.m_JournalMgr);
    this.m_AvatarController.SetHolder(this.m_Holder);
    this.m_AvatarController.RegisterToCallback(n"OnStateChanged", this, n"OnElementStateChanged");
    this.options.loopType = inkanimLoopType.Cycle;
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_Blackboard) {
      this.m_Blackboard.UnregisterDelayedListener(this.m_BlackboardDef.PhoneCallInformation, this.m_CallInformationBBID);
      this.m_Blackboard.UnregisterDelayedListener(this.m_BlackboardDef.PhoneStyle_Minimized, this.m_MinimizedListener);
    };
    this.m_AvatarController.UnregisterFromCallback(n"OnStateChanged", this, n"OnElementStateChanged");
    this.UnregisterScreenProjection(this.m_updatesProjection);
    this.m_Blackboard = null;
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    playerPuppet.RegisterInputListener(this, n"PhoneInteract");
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    playerPuppet.UnregisterInputListener(this);
  }

  private final func CachePredefinedRestrictions() -> Void {
    PlayerGameplayRestrictions.AcquireHotkeyRestrictionTags(EHotkey.DPAD_DOWN, this.m_gameplayRestrictions);
  }

  private final func IsUsingPhonePrevented() -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffectWithTags(this.m_Owner, this.m_gameplayRestrictions);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let pickupRequest: ref<PickupPhoneRequest>;
    let playerStatsBB: ref<IBlackboard>;
    let uiActionPerformed: ref<DPADActionPerformed>;
    let wheelOpened: Bool = GameInstance.GetBlackboardSystem(this.m_Owner.GetGame()).Get(GetAllBlackboardDefs().UI_QuickSlotsData).GetBool(GetAllBlackboardDefs().UI_QuickSlotsData.UIRadialContextRequest);
    let hacksOpened: Bool = GameInstance.GetBlackboardSystem(this.m_Owner.GetGame()).Get(GetAllBlackboardDefs().UI_QuickSlotsData).GetBool(GetAllBlackboardDefs().UI_QuickSlotsData.quickhackPanelOpen);
    let actionName: CName = ListenerAction.GetName(action);
    let actionType: gameinputActionType = ListenerAction.GetType(action);
    if Equals(actionName, n"PhoneInteract") && !this.IsUsingPhonePrevented() {
      uiActionPerformed = new DPADActionPerformed();
      uiActionPerformed.action = EHotkey.DPAD_DOWN;
      if Equals(actionType, gameinputActionType.BUTTON_PRESSED) {
        if this.m_Owner.PlayerLastUsedPad() {
          uiActionPerformed.state = EUIActionState.STARTED;
          uiActionPerformed.successful = true;
          this.m_buttonPressed = true;
          GameInstance.GetUISystem(this.m_Owner.GetGame()).QueueEvent(uiActionPerformed);
        };
        if Equals(this.m_CurrentCallInformation.callPhase, questPhoneCallPhase.IncomingCall) {
          pickupRequest = new PickupPhoneRequest();
          pickupRequest.CallInformation = this.m_CurrentCallInformation;
          this.m_PhoneSystem.QueueRequest(pickupRequest);
          return true;
        };
      };
      if Equals(actionType, this.DeductGameInputActionType()) {
        if !wheelOpened && !hacksOpened {
          playerStatsBB = GameInstance.GetBlackboardSystem(this.m_Owner.GetGame()).Get(GetAllBlackboardDefs().UI_PlayerStats);
          if !playerStatsBB.GetBool(GetAllBlackboardDefs().UI_PlayerStats.isReplacer) {
            this.m_PhoneSystem.QueueRequest(new UsePhoneRequest());
            uiActionPerformed.successful = true;
            uiActionPerformed.state = EUIActionState.COMPLETED;
            this.m_buttonPressed = false;
            GameInstance.GetUISystem(this.m_Owner.GetGame()).QueueEvent(uiActionPerformed);
            return true;
          };
        } else {
          GameInstance.GetUISystem(this.m_Owner.GetGame()).QueueEvent(uiActionPerformed);
        };
      };
      if Equals(actionType, gameinputActionType.BUTTON_RELEASED) && this.m_buttonPressed {
        this.m_buttonPressed = false;
        uiActionPerformed.state = EUIActionState.ABORTED;
        uiActionPerformed.successful = false;
        GameInstance.GetUISystem(this.m_Owner.GetGame()).QueueEvent(uiActionPerformed);
      };
    };
    return false;
  }

  private final func DeductGameInputActionType() -> gameinputActionType {
    if this.m_Owner.PlayerLastUsedKBM() {
      return gameinputActionType.BUTTON_RELEASED;
    };
    return gameinputActionType.BUTTON_HOLD_COMPLETE;
  }

  protected cb func OnPhoneMinimize(value: Bool) -> Bool {
    this.m_AvatarController.ChangeMinimized(value);
  }

  protected cb func OnPhoneStatusChanged(phoneStatus: CName) -> Bool {
    this.m_AvatarController.SetStatusText(NameToString(phoneStatus));
  }

  protected cb func OnTriggerCall(data: Variant) -> Bool {
    this.m_CurrentCallInformation = FromVariant(data);
    this.m_CurrentPhoneCallContact = this.GetIncomingContact();
    this.CancelQuestFailsafe();
    this.CancelTimeoutFailsafe();
    this.m_RootWidget.SetVisible(true);
    inkWidgetRef.SetVisible(this.m_Holder, true);
    if IsDefined(this.m_CurrentPhoneCallContact) {
      switch this.m_CurrentCallInformation.callPhase {
        case questPhoneCallPhase.EndCall:
        case questPhoneCallPhase.Undefined:
          this.SetTalkingTrigger(this.m_CurrentCallInformation.isPlayerCalling, questPhoneTalkingState.Ended);
          this.SetPhoneFunction(EHudPhoneFunction.Inactive);
          break;
        case questPhoneCallPhase.IncomingCall:
          this.PlaySound(n"PhoneCallPopup", n"OnOpen");
          this.StartTimeoutFailsafe();
          this.SetPhoneFunction(EHudPhoneFunction.IncomingCall);
          break;
        case questPhoneCallPhase.StartCall:
          this.SetTalkingTrigger(this.m_CurrentCallInformation.isPlayerCalling, questPhoneTalkingState.Talking);
          this.SetPhoneFunction(this.m_CurrentCallInformation.isAudioCall ? EHudPhoneFunction.Audiocall : EHudPhoneFunction.Holocall);
      };
    };
  }

  protected cb func OnQuestTimer(value: Float) -> Bool {
    let projectionData: inkScreenProjectionData;
    if value > 0.00 {
      this.m_updatesProjection = this.RegisterScreenProjection(projectionData);
    };
  }

  public final func CancelQuestFailsafe() -> Void {
    if IsDefined(this.m_DelaySystem) {
      this.m_DelaySystem.CancelCallback(this.m_DelayedCallbackId);
    };
  }

  public final func StartTimeoutFailsafe() -> Void {
    let timeoutRequest: ref<PhoneTimeoutRequest> = new PhoneTimeoutRequest();
    if IsDefined(this.m_DelaySystem) {
      this.m_DelayedTimeoutCallbackId = this.m_DelaySystem.DelayScriptableSystemRequest(n"PhoneSystem", timeoutRequest, this.m_TimeoutPeroid);
    };
  }

  public final func CancelTimeoutFailsafe() -> Void {
    if IsDefined(this.m_DelaySystem) {
      this.m_DelaySystem.CancelCallback(this.m_DelayedTimeoutCallbackId);
    };
  }

  private final func SetTalkingTrigger(isPlayerCalling: Bool, state: questPhoneTalkingState) -> Void {
    let request: ref<TalkingTriggerRequest>;
    if IsDefined(this.m_CurrentPhoneCallContact) {
      request = new TalkingTriggerRequest();
      request.isPlayerCalling = isPlayerCalling;
      request.contact = StringToName(this.m_CurrentPhoneCallContact.GetId());
      request.state = state;
      this.m_PhoneSystem.QueueRequest(request);
    };
  }

  private final func GetIncomingContact() -> wref<JournalContact> {
    let contactName: CName;
    let contactsList: array<wref<JournalEntry>>;
    let context: JournalRequestContext;
    let currContact: wref<JournalContact>;
    let i: Int32;
    let limit: Int32;
    if IsDefined(this.m_Blackboard) {
      context.stateFilter.active = true;
      context.stateFilter.inactive = true;
      contactName = this.m_CurrentCallInformation.contactName;
      this.m_JournalMgr.GetContacts(context, contactsList);
      i = 0;
      limit = ArraySize(contactsList);
      while i < limit {
        currContact = contactsList[i] as JournalContact;
        if Equals(currContact.GetId(), NameToString(contactName)) {
          return currContact;
        };
        i += 1;
      };
    };
    return null;
  }

  protected cb func OnElementStateChanged(widget: wref<inkWidget>, oldState: CName, newState: CName) -> Bool;

  public final func SetPhoneFunction(newFunction: EHudPhoneFunction) -> Void {
    if NotEquals(this.m_CurrentFunction, newFunction) {
      this.m_CurrentFunction = newFunction;
      switch newFunction {
        case EHudPhoneFunction.DisplayingMessage:
          break;
        case EHudPhoneFunction.IncomingCall:
          this.m_AvatarController.ShowIncomingContact(this.m_CurrentPhoneCallContact);
          break;
        case EHudPhoneFunction.Audiocall:
          this.m_AvatarController.StartAudiocall(this.m_CurrentPhoneCallContact);
          break;
        case EHudPhoneFunction.Holocall:
          this.m_AvatarController.StartHolocall(this.m_CurrentPhoneCallContact);
      };
      if Equals(newFunction, EHudPhoneFunction.Inactive) {
        this.m_AvatarController.ShowEndCallContact(this.m_CurrentPhoneCallContact);
        this.m_RootWidget.SetVisible(false);
        inkWidgetRef.SetVisible(this.m_Holder, false);
      };
    };
  }
}

public abstract class HUDPhoneElement extends inkLogicController {

  protected let m_RootWidget: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_RootWidget = this.GetRootWidget();
    this.m_RootWidget.RegisterToCallback(n"OnStateChanged", this, n"OnStateChanged");
    this.SetState(EHudPhoneVisibility.Invisible);
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_RootWidget) {
      this.m_RootWidget.UnregisterFromCallback(n"OnStateChanged", this, n"OnStateChanged");
    };
  }

  protected cb func OnStateChanged(widget: wref<inkWidget>, oldState: CName, newState: CName) -> Bool;

  public final func SetState(visibility: EHudPhoneVisibility) -> Void {
    let stateName: CName;
    switch visibility {
      case EHudPhoneVisibility.Invisible:
        stateName = n"Invisible";
        break;
      case EHudPhoneVisibility.Showing:
        stateName = n"Showing";
        break;
      case EHudPhoneVisibility.Visible:
        stateName = n"Visible";
        break;
      case EHudPhoneVisibility.Hiding:
        stateName = n"Hiding";
    };
    this.m_RootWidget.SetState(stateName);
  }

  protected final func GetStateFromName(stateName: CName) -> EHudPhoneVisibility {
    switch stateName {
      case n"Invisible":
        return EHudPhoneVisibility.Invisible;
      case n"Showing":
        return EHudPhoneVisibility.Showing;
      case n"Hiding":
        return EHudPhoneVisibility.Hiding;
    };
    return EHudPhoneVisibility.Visible;
  }

  public final func GetState() -> EHudPhoneVisibility {
    return this.GetStateFromName(this.m_RootWidget.GetState());
  }

  public final func Show() -> Void {
    let state: EHudPhoneVisibility = this.GetState();
    if NotEquals(state, EHudPhoneVisibility.Visible) && NotEquals(state, EHudPhoneVisibility.Showing) {
      this.SetState(EHudPhoneVisibility.Showing);
    };
  }

  public final func Hide() -> Void {
    let state: EHudPhoneVisibility = this.GetState();
    if NotEquals(state, EHudPhoneVisibility.Invisible) && NotEquals(state, EHudPhoneVisibility.Hiding) {
      this.SetState(EHudPhoneVisibility.Hiding);
    };
  }
}
