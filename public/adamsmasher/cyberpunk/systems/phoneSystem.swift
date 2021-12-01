
public class PhoneSystem extends ScriptableSystem {

  private let m_BlackboardSystem: ref<BlackboardSystem>;

  private let m_Blackboard: wref<IBlackboard>;

  private let m_LastCallInformation: PhoneCallInformation;

  @default(PhoneSystem, false)
  private let m_ContactsOpen: Bool;

  private let ContactsOpenBBId: ref<CallbackHandle>;

  private final func IsShowingMessage() -> Bool {
    return this.m_Blackboard.GetBool(GetAllBlackboardDefs().UI_ComDevice.isDisplayingMessage);
  }

  private final func OnSetPhoneStatus(request: ref<questSetPhoneStatusRequest>) -> Void {
    this.m_Blackboard.SetName(GetAllBlackboardDefs().UI_ComDevice.comDeviceSetStatusText, request.status, true);
  }

  private final func OnTriggerCall(request: ref<questTriggerCallRequest>) -> Void {
    let contactName: CName;
    let shouldPlayIncomingCallSound: Bool = Equals(request.callPhase, questPhoneCallPhase.IncomingCall);
    if Equals(request.callPhase, questPhoneCallPhase.IncomingCall) || Equals(request.callPhase, questPhoneCallPhase.StartCall) {
      this.ToggleContacts(false);
    };
    if IsNameValid(request.caller) && NotEquals(request.caller, n"player") && NotEquals(request.caller, n"Player") {
      if shouldPlayIncomingCallSound {
        GameInstance.GetAudioSystem(GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject().GetGame()).Play(n"ui_phone_incoming_call");
      };
      contactName = request.caller;
    } else {
      if IsNameValid(request.addressee) && NotEquals(request.addressee, n"player") && NotEquals(request.addressee, n"Player") {
        if shouldPlayIncomingCallSound {
          GameInstance.GetAudioSystem(GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject().GetGame()).Play(n"ui_phone_initiation_call");
        };
        contactName = request.addressee;
      };
    };
    if IsNameValid(contactName) {
      this.TriggerCall(request.callMode, Equals(request.callMode, questPhoneCallMode.Audio), contactName, Equals(request.caller, n"Player") || Equals(request.caller, n"player"), request.callPhase, request.isPlayerTriggered);
    };
  }

  private final func TriggerCall(callMode: questPhoneCallMode, isAudio: Bool, contactName: CName, isPlayerCalling: Bool, callPhase: questPhoneCallPhase, isPlayerTriggered: Bool) -> Void {
    let state: questPhoneTalkingState;
    this.m_LastCallInformation = new PhoneCallInformation(callMode, isAudio, contactName, isPlayerCalling, isPlayerTriggered, callPhase);
    this.m_Blackboard.SetVariant(GetAllBlackboardDefs().UI_ComDevice.PhoneCallInformation, ToVariant(this.m_LastCallInformation), true);
    if Equals(callPhase, questPhoneCallPhase.EndCall) {
      state = questPhoneTalkingState.Ended;
      if isPlayerTriggered {
        GameInstance.GetPhoneManager(this.GetGameInstance()).ApplyPhoneCallRestriction(false);
      };
    } else {
      state = questPhoneTalkingState.Initializing;
      if isPlayerTriggered {
        GameInstance.GetPhoneManager(this.GetGameInstance()).ApplyPhoneCallRestriction(true);
      };
    };
    this.SetPhoneFact(isPlayerCalling, contactName, state);
  }

  private final func OnPickupPhone(request: ref<PickupPhoneRequest>) -> Void {
    if Equals(this.m_LastCallInformation.callPhase, questPhoneCallPhase.IncomingCall) && Equals(request.CallInformation.contactName, this.m_LastCallInformation.contactName) {
      GameInstance.GetAudioSystem(GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject().GetGame()).Play(n"ui_phone_initiation_call_stop");
      GameInstance.GetAudioSystem(GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject().GetGame()).Play(n"ui_phone_incoming_call_stop");
      this.SetPhoneFact(request.CallInformation.isPlayerCalling, request.CallInformation.contactName, questPhoneTalkingState.Talking);
    };
  }

  private final func OnPhoneTimeoutRequest(request: ref<PhoneTimeoutRequest>) -> Void {
    if Equals(this.m_LastCallInformation.callPhase, questPhoneCallPhase.IncomingCall) {
      this.TriggerCall(questPhoneCallMode.Undefined, this.m_LastCallInformation.isAudioCall, this.m_LastCallInformation.contactName, this.m_LastCallInformation.isPlayerCalling, questPhoneCallPhase.EndCall, this.m_LastCallInformation.isPlayerTriggered);
    };
  }

  private final func OnUsePhone(request: ref<UsePhoneRequest>) -> Void {
    let localPlayer: wref<GameObject>;
    let notificationEvent: ref<UIInGameNotificationEvent>;
    let psmBlackboard: ref<IBlackboard>;
    let tier: Int32 = psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel);
    if this.IsShowingMessage() {
      return;
    };
    localPlayer = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject();
    psmBlackboard = GameInstance.GetBlackboardSystem(localPlayer.GetGame()).GetLocalInstanced(localPlayer.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    if Equals(this.m_LastCallInformation.callPhase, questPhoneCallPhase.IncomingCall) {
      if this.m_LastCallInformation.isPlayerCalling {
        GameInstance.GetAudioSystem(localPlayer.GetGame()).Play(n"ui_phone_incoming_call_stop");
        this.TriggerCall(questPhoneCallMode.Undefined, this.m_LastCallInformation.isAudioCall, this.m_LastCallInformation.contactName, this.m_LastCallInformation.isPlayerCalling, questPhoneCallPhase.EndCall, this.m_LastCallInformation.isPlayerTriggered);
      } else {
        GameInstance.GetAudioSystem(localPlayer.GetGame()).Play(n"ui_phone_incoming_call_positive");
        GameInstance.GetAudioSystem(localPlayer.GetGame()).Play(n"ui_phone_incoming_call_stop");
        this.SetPhoneFact(this.m_LastCallInformation.isPlayerCalling, this.m_LastCallInformation.contactName, questPhoneTalkingState.Talking);
      };
    } else {
      if tier >= EnumInt(gamePSMHighLevel.SceneTier3) && tier <= EnumInt(gamePSMHighLevel.SceneTier5) || StatusEffectSystem.ObjectHasStatusEffectWithTag(localPlayer, n"NoPhone") {
        GameInstance.GetUISystem(localPlayer.GetGame()).QueueEvent(new UIInGameNotificationRemoveEvent());
        notificationEvent = new UIInGameNotificationEvent();
        notificationEvent.m_notificationType = UIInGameNotificationType.ActionRestriction;
        GameInstance.GetUISystem(localPlayer.GetGame()).QueueEvent(notificationEvent);
        return;
      };
      if Equals(this.m_LastCallInformation.callPhase, questPhoneCallPhase.Undefined) || Equals(this.m_LastCallInformation.callPhase, questPhoneCallPhase.EndCall) {
        if !this.m_ContactsOpen {
          this.ToggleContacts(true);
        };
      };
    };
  }

  private final func ToggleContacts(open: Bool) -> Void {
    this.m_Blackboard.SetBool(GetAllBlackboardDefs().UI_ComDevice.ContactsActive, open, true);
  }

  private final func OnContactsStateChanged(newState: Bool) -> Void {
    this.m_ContactsOpen = newState;
  }

  private final func OnTalkingTriggerRequest(request: ref<TalkingTriggerRequest>) -> Void {
    GameInstance.GetAudioSystem(GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject().GetGame()).Play(n"ui_phone_initiation_call_stop");
    GameInstance.GetAudioSystem(GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject().GetGame()).Play(n"ui_phone_incoming_call_stop");
    GameInstance.GetAudioSystem(GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject().GetGame()).Play(n"ui_phone_incoming_call_positive");
    this.SetPhoneFact(request.isPlayerCalling, request.contact, request.state);
  }

  private final func OnMinimizeCallRequest(request: ref<questMinimizeCallRequest>) -> Void {
    this.m_LastCallInformation.isAudioCall = request.minimized;
    this.m_LastCallInformation.callMode = request.minimized ? questPhoneCallMode.Audio : questPhoneCallMode.Video;
    this.m_Blackboard.SetVariant(GetAllBlackboardDefs().UI_ComDevice.PhoneCallInformation, ToVariant(this.m_LastCallInformation), false);
    this.m_Blackboard.SetBool(GetAllBlackboardDefs().UI_ComDevice.PhoneStyle_Minimized, request.minimized, true);
  }

  private final func SetPhoneFact(isPlayerCalling: Bool, contactName: CName, state: questPhoneTalkingState) -> Void {
    let factName: String;
    if isPlayerCalling {
      factName = this.GetPhoneCallFactName(n"player", contactName);
    } else {
      factName = this.GetPhoneCallFactName(contactName, n"player");
    };
    GameInstance.GetQuestsSystem(this.GetGameInstance()).SetFactStr(factName, EnumInt(state));
  }

  private func OnAttach() -> Void {
    this.m_BlackboardSystem = GameInstance.GetBlackboardSystem(this.GetGameInstance());
    this.m_Blackboard = this.m_BlackboardSystem.Get(GetAllBlackboardDefs().UI_ComDevice);
    this.ContactsOpenBBId = this.m_Blackboard.RegisterListenerBool(GetAllBlackboardDefs().UI_ComDevice.ContactsActive, this, n"OnContactsStateChanged");
  }

  private func OnDetach() -> Void {
    if IsDefined(this.m_Blackboard) {
      this.m_Blackboard.UnregisterListenerBool(GetAllBlackboardDefs().UI_ComDevice.ContactsActive, this.ContactsOpenBBId);
    };
  }

  public final const func IsPhoneAvailable() -> Bool {
    return Equals(this.m_LastCallInformation.callPhase, questPhoneCallPhase.Undefined) || Equals(this.m_LastCallInformation.callPhase, questPhoneCallPhase.EndCall) || Equals(this.m_LastCallInformation.callPhase, questPhoneCallPhase.IncomingCall);
  }

  public final const func GetPhoneCallFactName(contactName1: CName, contactName2: CName) -> String {
    return "phonecall_" + StrLower(NameToString(contactName1)) + "_with_" + StrLower(NameToString(contactName2));
  }
}
