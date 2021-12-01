
public class InteractiveDevice extends Device {

  protected let m_interaction: ref<InteractionComponent>;

  protected let m_interactionIndicator: ref<gameLightComponent>;

  protected let m_disableAreaIndicatorID: DelayID;

  protected let m_delayedUIRefreshID: DelayID;

  private let m_isPlayerAround: Bool;

  protected let m_disableAreaIndicatorDelayActive: Bool;

  private let m_objectActionsCallbackCtrl: ref<gameObjectActionsCallbackController>;

  private let m_investigationPositionsArray: array<Vector4>;

  private let m_actionRestrictionPlayerBB: wref<IBlackboard>;

  private let m_actionRestrictionCallbackID: ref<CallbackHandle>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"interaction", n"gameinteractionsComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"state_indicator_light", n"gameLightComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"audio", n"soundComponent", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_interaction = EntityResolveComponentsInterface.GetComponent(ri, n"interaction") as InteractionComponent;
    this.m_interactionIndicator = EntityResolveComponentsInterface.GetComponent(ri, n"state_indicator_light") as gameLightComponent;
    super.OnTakeControl(ri);
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
    this.DestroyObjectActionsCallbackController();
    if IsDefined(this.m_uiComponent) {
      this.UnregisterActionRestrictionCallback();
    };
  }

  protected final func ToggleDirectLayer(input: Bool) -> Void {
    let evt: ref<InteractionSetEnableEvent> = new InteractionSetEnableEvent();
    evt.enable = input;
    evt.layer = n"direct";
    this.QueueEvent(evt);
  }

  protected final func ToggleLogicLayer(input: Bool) -> Void {
    let evt: ref<InteractionSetEnableEvent> = new InteractionSetEnableEvent();
    evt.enable = input;
    evt.layer = n"logic";
    this.QueueEvent(evt);
  }

  protected func DeactivateDevice() -> Void {
    this.DeactivateDevice();
    this.m_isPlayerAround = false;
    if IsDefined(this.m_interaction) {
      this.m_interaction.Toggle(false);
    };
  }

  protected func ActivateDevice() -> Void {
    if IsDefined(this.m_interaction) {
      this.m_interaction.Toggle(true);
    };
    this.m_isUIdirty = true;
    this.ActivateDevice();
  }

  protected func CutPower() -> Void {
    this.m_isPlayerAround = false;
    this.CutPower();
  }

  protected func TurnOnDevice() -> Void {
    if IsDefined(this.m_interaction) {
      this.m_interaction.Toggle(true);
    };
    this.TurnOnIndicator();
    this.TurnOnDevice();
  }

  protected func TurnOffDevice() -> Void {
    this.m_isPlayerAround = false;
    this.TurnOffIndicator();
    this.TurnOffDevice();
  }

  protected func UpdateDeviceState(opt isDelayed: Bool) -> Bool {
    if this.UpdateDeviceState(isDelayed) {
      if this.GetDevicePS().HasPlaystyle(EPlaystyle.NETRUNNER) {
        QuickhackModule.RequestRefreshQuickhackMenu(this.GetGame(), this.GetEntityID());
      };
      if !this.IsActive() {
        if this.GetDevicePS().IsDistracting() || this.GetDevicePS().IsGlitching() {
          this.GetDevicePS().FinishDistraction();
        };
      };
      return true;
    };
    return false;
  }

  protected func TurnOnIndicator() -> Void {
    if IsDefined(this.m_interactionIndicator) {
      this.m_interactionIndicator.ToggleLight(true);
    };
  }

  protected func TurnOffIndicator() -> Void {
    if IsDefined(this.m_interactionIndicator) {
      this.m_interactionIndicator.ToggleLight(false);
    };
  }

  public const func IsPlayerAround() -> Bool {
    return this.m_isPlayerAround;
  }

  protected cb func OnInteractionActivated(evt: ref<InteractionActivationEvent>) -> Bool {
    let generatedContext: GetActionsContext;
    let processInitiatorObject: wref<GameObject>;
    let radialRequest: ref<ResolveQuickHackRadialRequest>;
    let requestType: gamedeviceRequestType;
    if this.GetDevicePS().GetDeviceOperationsContainer() != null {
      this.GetDevicePS().GetDeviceOperationsContainer().EvaluateInteractionAreaTriggers(evt.layerData.tag, this, evt.activator, evt.eventType);
    };
    if !IsDefined(evt.activator as PlayerPuppet) && !IsDefined(evt.activator as Muppet) {
      return false;
    };
    this.EstimateIfPlayerEntersOrLeaves(evt);
    if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_activate) {
      if Equals(evt.layerData.tag, n"LogicArea") {
        this.m_isInsideLogicArea = true;
        if this.IsVisible() {
          this.RefreshUI();
        };
        this.EvaluateProximityMappinInteractionLayerState();
        this.EvaluateProximityRevealInteractionLayerState();
        if IsDefined(this.m_uiComponent) && this.IsGameplayRelevant() {
          this.RegisterActionRestrictionCallback();
        };
      };
      if Equals(evt.layerData.tag, n"direct") {
        requestType = gamedeviceRequestType.Direct;
        processInitiatorObject = evt.activator;
        this.GetDevicePS().AddActiveContext(gamedeviceRequestType.Direct);
        if IsDefined(evt.hotspot as Door) {
          this.SetIsDoorInteractionActiveBB(evt, true);
        };
        this.CreateObjectActionsCallbackController(evt.activator);
        if this.IsUIdirty() {
          this.RefreshUI();
        };
      };
      if Equals(evt.layerData.tag, n"ForceReveal") {
        this.StartRevealingOnProximity();
      };
      if Equals(evt.layerData.tag, n"ForceShowIcon") {
        this.ShowMappinOnProximity();
      };
      this.RequestDebuggerRegistration(evt.activator as ScriptedPuppet);
      if Equals(requestType, gamedeviceRequestType.Direct) || Equals(requestType, gamedeviceRequestType.Remote) {
        generatedContext = this.GetDevicePS().GenerateContext(requestType, Device.GetInteractionClearance(), processInitiatorObject);
        this.DetermineInteractionState(generatedContext);
      };
    } else {
      if IsDefined(this.m_interaction) {
        this.m_interaction.ResetChoices(n"", true);
      };
      if Equals(evt.layerData.tag, n"LogicArea") {
        this.ResolveGameplayObjectives(false);
        this.m_isInsideLogicArea = false;
        if IsDefined(this.m_uiComponent) {
          this.UnregisterActionRestrictionCallback();
        };
      };
      if Equals(evt.layerData.tag, n"direct") {
        this.DestroyObjectActionsCallbackController();
        this.GetDevicePS().RemoveActiveContext(gamedeviceRequestType.Direct);
        if IsDefined(evt.hotspot as Door) {
          this.SetIsDoorInteractionActiveBB(evt, false);
        };
      };
      if Equals(evt.layerData.tag, n"ForceReveal") {
        this.StopRevealingOnProximity(this.GetRevealOnProximityStopLifetimeValue());
      };
      if Equals(evt.layerData.tag, n"ForceShowIcon") {
        this.HideMappinOnProximity();
      };
    };
    radialRequest = new ResolveQuickHackRadialRequest();
    this.GetHudManager().QueueRequest(radialRequest);
    if !IsFinal() {
      this.UpdateDebugInfo();
    };
  }

  protected func OnVisibilityChanged() -> Void {
    if this.IsReadyForUI() && this.IsUIdirty() {
      this.RefreshUI();
    };
  }

  protected cb func OnLogicReady(evt: ref<SetLogicReadyEvent>) -> Bool {
    super.OnLogicReady(evt);
    if this.IsPotentiallyQuickHackable() {
      this.m_investigationPositionsArray = this.GetNodePosition();
    };
  }

  protected const func GetCachedInvestigationPositionsArray() -> array<Vector4> {
    return this.m_investigationPositionsArray;
  }

  protected func SetInvestigationPositionsArray(arr: array<Vector4>) -> Void {
    this.m_investigationPositionsArray = arr;
  }

  protected const func HasInvestigationPositionsArrayCached() -> Bool {
    return ArraySize(this.m_investigationPositionsArray) > 0;
  }

  protected func SetIsDoorInteractionActiveBB(evt: ref<InteractionActivationEvent>, isActive: Bool) -> Void {
    let playerSMBlackboard: ref<IBlackboard> = this.GetPlayerStateMachineBB(evt.activator);
    playerSMBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsDoorInteractionActive, isActive);
  }

  private final func GetPlayerStateMachineBB(requester: ref<GameObject>) -> ref<IBlackboard> {
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(requester.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let playerStateMachineBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(requester.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return playerStateMachineBlackboard;
  }

  protected cb func OnInteractionUsed(evt: ref<InteractionChoiceEvent>) -> Bool {
    this.ExecuteAction(evt.choice, evt.activator, evt.layerData.tag);
  }

  protected cb func OnPerformedAction(evt: ref<PerformedAction>) -> Bool {
    let currentContext: GetActionsContext;
    let sDeviceAction: ref<ScriptableDeviceAction>;
    super.OnPerformedAction(evt);
    sDeviceAction = evt.m_action as ScriptableDeviceAction;
    if IsDefined(sDeviceAction) && this.GetDevicePS().HasActiveContext(gamedeviceRequestType.Direct) || this.GetDevicePS().HasActiveContext(gamedeviceRequestType.Remote) {
      currentContext = this.GetDevicePS().GenerateContext(sDeviceAction.GetRequestType(), Device.GetInteractionClearance(), sDeviceAction.GetExecutor());
      this.DetermineInteractionState(currentContext);
    };
  }

  protected final func RefreshInteraction(requestType: gamedeviceRequestType, executor: wref<GameObject>) -> Void {
    let taskData: ref<RefreshInteractionTaskData> = new RefreshInteractionTaskData();
    taskData.requestType = requestType;
    taskData.executor = executor;
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, taskData, n"RefreshInteractionTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func RefreshInteractionTask(data: ref<ScriptTaskData>) -> Void {
    let taskData: ref<RefreshInteractionTaskData> = data as RefreshInteractionTaskData;
    let currentContext: GetActionsContext = this.GetDevicePS().GenerateContext(taskData.requestType, Device.GetInteractionClearance(), taskData.executor);
    this.DetermineInteractionState(currentContext);
  }

  private final func EstimateIfPlayerEntersOrLeaves(evt: ref<InteractionActivationEvent>) -> Void {
    if NotEquals(evt.layerData.tag, n"LogicArea") {
      return;
    };
    if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_activate) {
      this.m_isPlayerAround = true;
    } else {
      this.m_isPlayerAround = false;
    };
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let playerPuppet: ref<PlayerPuppet>;
    if Equals(ListenerAction.GetName(action), n"UI_Exit") {
      playerPuppet = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
      this.SetZoomBlackboardValues(false);
      this.RemoveHudButtonHelper();
      this.RegisterPlayerInputListener(false);
      this.ToggleCameraZoom(false);
      this.GetDevicePS().SetAdvancedInteractionModeOn(false);
      this.RefreshInteraction(gamedeviceRequestType.Direct, playerPuppet);
    };
  }

  protected cb func OnUIRefreshedEvent(evt: ref<UIRefreshedEvent>) -> Bool {
    this.m_isUIdirty = false;
  }

  protected cb func OnUIUnstreamedEvent(evt: ref<UIUnstreamedEvent>) -> Bool {
    this.m_isUIdirty = true;
  }

  protected func RefreshUI(opt isDelayed: Bool) -> Void {
    let evt: ref<DelayedUIRefreshEvent>;
    if IsDefined(this.m_uiComponent) {
      if this.m_delayedUIRefreshID != GetInvalidDelayID() {
        return;
      };
      if isDelayed {
        evt = new DelayedUIRefreshEvent();
        this.m_delayedUIRefreshID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, 0.10, false);
      } else {
        this.GetDevicePS().RefreshUI(this.GetBlackboard());
      };
    };
  }

  protected cb func OnForceUIRefreshEvent(evt: ref<ForceUIRefreshEvent>) -> Bool {
    this.RefreshUI();
  }

  protected cb func OnDelayedUIRefreshEvent(evt: ref<DelayedUIRefreshEvent>) -> Bool {
    this.m_delayedUIRefreshID = GetInvalidDelayID();
    this.m_isUIdirty = false;
    this.GetDevicePS().RefreshUI(this.GetBlackboard());
  }

  public const func IsReadyForUI() -> Bool {
    return this.m_isVisible && this.m_isInsideLogicArea || this.GetDevicePS().ForceResolveGameplayStateOnAttach();
  }

  protected func DetermineInteractionState(opt context: GetActionsContext) -> Void {
    let currentlyUsedContext: GetActionsContext;
    let player: ref<GameObject> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject();
    if Equals(context.requestType, gamedeviceRequestType.Direct) || Equals(context.requestType, gamedeviceRequestType.Remote) {
      currentlyUsedContext = context;
      if currentlyUsedContext.processInitiatorObject == null {
        currentlyUsedContext.processInitiatorObject = player;
      };
    } else {
      if this.GetDevicePS().HasActiveContext(gamedeviceRequestType.Remote) {
        currentlyUsedContext = this.GetDevicePS().GenerateContext(gamedeviceRequestType.Remote, Device.GetInteractionClearance(), player, this.GetEntityID());
      } else {
        currentlyUsedContext = this.GetDevicePS().GenerateContext(gamedeviceRequestType.Direct, Device.GetInteractionClearance(), player, this.GetEntityID());
      };
    };
    this.GetDevicePS().DetermineInteractionState(this.m_interaction, currentlyUsedContext);
  }

  protected func ResetChoicesByEvent() -> Void {
    let evt: ref<InteractionResetChoicesEvent> = new InteractionResetChoicesEvent();
    this.QueueEvent(evt);
  }

  protected cb func OnToggleUIInteractivity(evt: ref<ToggleUIInteractivity>) -> Bool {
    super.OnToggleUIInteractivity(evt);
    this.ToggleDirectLayer(evt.m_isInteractive);
  }

  protected func StartUsing() -> Void;

  protected func StopUsing() -> Void;

  private final func RequestDebuggerRegistration(activator: ref<ScriptedPuppet>) -> Void {
    if !IsDefined(activator) {
      return;
    };
    if this.ShouldInitiateDebug() {
      ScriptedPuppet.RequestDeviceDebug(activator, this);
    };
  }

  private final func UpdateDebugInfo() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_debugOptions.m_layerIDs) {
      GameInstance.GetDebugVisualizerSystem(this.GetGame()).ClearLayer(this.m_debugOptions.m_layerIDs[i]);
      ArrayClear(this.m_debugOptions.m_layerIDs);
      i += 1;
    };
    if this.ShouldInitiateDebug() {
      this.PrintWorldSpaceDebug();
    };
  }

  private final func PrintWorldSpaceDebug() -> Void {
    let interactionPositionMatrix: Matrix;
    let position: Vector4;
    if IsDefined(this.m_interaction) {
      interactionPositionMatrix = this.m_interaction.GetLocalToWorld();
      position = Matrix.GetTranslation(interactionPositionMatrix);
      ArrayPush(this.m_debugOptions.m_layerIDs, GameInstance.GetDebugVisualizerSystem(this.GetGame()).DrawText3D(position, "TO DO", SColor.Red()));
    };
  }

  public const func GetNetworkBeamEndpoint() -> Vector4 {
    let beamPos: Vector4;
    let offset: Vector4;
    let transform: WorldTransform;
    if !this.GetUISlotComponent().GetSlotTransform(n"NetworkLink", transform) {
      WorldTransform.SetPosition(transform, this.GetWorldPosition());
      WorldTransform.SetOrientation(transform, this.GetWorldOrientation());
      if IsDefined(this.m_interaction) {
        offset = this.m_interaction.GetLocalPosition() + this.m_networkGridBeamOffset;
      };
      beamPos = WorldPosition.ToVector4(WorldTransform.TransformPoint(transform, offset));
    } else {
      beamPos = this.GetNetworkBeamEndpoint();
    };
    return beamPos;
  }

  protected const func HasAnyDirectInteractionActive() -> Bool {
    let actions: array<ref<DeviceAction>>;
    let player: ref<GameObject> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject();
    let currentlyUsedContext: GetActionsContext = this.GetDevicePS().GenerateContext(gamedeviceRequestType.Direct, Device.GetInteractionClearance(), player, this.GetEntityID());
    this.GetDevicePS().GetActions(actions, currentlyUsedContext);
    return ArraySize(actions) > 0;
  }

  protected cb func OnEMPHitEvent(evt: ref<EMPHitEvent>) -> Bool {
    let empEnded: ref<EMPEnded>;
    if this.IsActive() {
      GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Start, n"emp_hit");
      this.ExecuteAction(this.GetDevicePS().ActionSetDeviceUnpowered());
      empEnded = new EMPEnded();
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, empEnded, evt.lifetime);
    };
  }

  protected cb func OnEMPEnded(evt: ref<EMPEnded>) -> Bool {
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.BreakLoop, n"emp_hit");
    this.ExecuteAction(this.GetDevicePS().ActionSetDevicePowered());
  }

  protected cb func OnSetUICameraZoomEvent(evt: ref<SetUICameraZoomEvent>) -> Bool {
    let action: ref<DeviceAction>;
    if !this.GetDevicePS().AllowsUICameraZoomDynamicSwitch() {
      return false;
    };
    if NotEquals(this.GetDevicePS().HasUICameraZoom(), evt.hasUICameraZoom) {
      if !evt.hasUICameraZoom && this.GetDevicePS().IsAdvancedInteractionModeOn() {
        action = this.GetDevicePS().ActionToggleZoomInteraction();
        this.ExecuteAction(action, GetPlayer(this.GetGame()));
      };
      this.GetDevicePS().SetHasUICameraZoom(evt.hasUICameraZoom);
      this.DetermineInteractionState();
    };
  }

  private final func CreateObjectActionsCallbackController(instigator: wref<Entity>) -> Void {
    this.m_objectActionsCallbackCtrl = gameObjectActionsCallbackController.Create(EntityGameInterface.GetEntity(this.GetEntity()), instigator, this.GetGame());
    this.m_objectActionsCallbackCtrl.RegisterSkillCheckCallbacks();
  }

  private final func DestroyObjectActionsCallbackController() -> Void {
    this.m_objectActionsCallbackCtrl.UnregisterSkillCheckCallbacks();
    this.m_objectActionsCallbackCtrl = null;
  }

  protected cb func OnObjectActionRefreshEvent(evt: ref<gameObjectActionRefreshEvent>) -> Bool {
    if IsDefined(this.m_objectActionsCallbackCtrl) {
      this.m_objectActionsCallbackCtrl.UnlockNotifications();
      this.DetermineInteractionState();
    };
  }

  private final func RegisterActionRestrictionCallback() -> Void {
    this.m_actionRestrictionPlayerBB = GetPlayer(this.GetGame()).GetPlayerStateMachineBlackboard();
    this.m_actionRestrictionCallbackID = this.m_actionRestrictionPlayerBB.RegisterListenerVariant(GetAllBlackboardDefs().PlayerStateMachine.ActionRestriction, this, n"OnActionRestrictionChanged");
  }

  private final func UnregisterActionRestrictionCallback() -> Void {
    if IsDefined(this.m_actionRestrictionCallbackID) {
      if IsDefined(this.m_actionRestrictionPlayerBB) {
        this.m_actionRestrictionPlayerBB.UnregisterListenerVariant(GetAllBlackboardDefs().PlayerStateMachine.ActionRestriction, this.m_actionRestrictionCallbackID);
      };
      this.m_actionRestrictionPlayerBB = null;
      this.m_actionRestrictionCallbackID = null;
    };
  }

  protected cb func OnActionRestrictionChanged(value: Variant) -> Bool {
    this.m_isUIdirty = true;
    if this.GetDevicePS().IsInDirectInteractionRange() {
      this.DetermineInteractionState();
      this.RefreshUI();
    } else {
      if this.IsReadyForUI() {
        this.RefreshUI();
      };
    };
  }
}
